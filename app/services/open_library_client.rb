require "net/http"
require "openssl"
require "json"

# talks to the Open Library API at https://openlibrary.org/developers/api 
# every hash uses the column names of the books table for merge convenience
# any network or API problem will raise OpenLibraryClient::Error.
class OpenLibraryClient
  class Error < StandardError; end

  BASE        = "https://openlibrary.org".freeze
  COVERS_BASE = "https://covers.openlibrary.org".freeze
  USER_AGENT  = "myBooks/1.0 (ssrith@proton.me)".freeze # OpenLibrary asks clients to identify themselves
  FIELDS      = %w[key title author_name first_publish_year number_of_pages_median subject cover_i].join(",").freeze
  COVER_SIZES = %w[S M L].freeze
  WORK_KEY    = /\A(?:\/works\/)?(OL\d+W)\z/
  MAX_DESCRIPTION = 2_000

  NETWORK_ERRORS = [
    Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, IOError,
    OpenSSL::SSL::SSLError, JSON::ParserError
  ].freeze

  # handle search results for the "add a book" page
  def self.search(query, limit: 20)
    return [] if query.to_s.strip.blank?

    docs(q: query.to_s.strip, limit: limit).filter_map { |doc| attributes_from_doc(doc) }
  end

  # full details of a book, used when a user adds a search result to the catalogue
  # or no results if not in OL's database
  def self.work(key)
    key = normalize_work_key(key) or return

    details = get_json("#{key}.json")
    return if details.nil? || details["title"].blank?

    # get description from OL
    attrs = attributes_from_doc(doc_for_key(key)) || attributes_from_work(details)
    attrs.merge(open_library_key: key, description: clean_description(details["description"]), genre: attrs[:genre] || Genre.classify(details["subjects"]))
  end

  # look up a book by title and author, return the first cover id
  def self.find_cover_id(title, author)
    docs(title: title, author: author, limit: 5).filter_map { |doc| doc["cover_i"] }.first
  end

  # URL of a cover image on covers.openlibrary.org - they provide Small, Medium and Large
  def self.cover_url(cover_id, size: "M")
    return if cover_id.blank?

    size = size.to_s.upcase
    size = "M" unless COVER_SIZES.include?(size)
    "#{COVERS_BASE}/b/id/#{cover_id.to_i}-#{size}.jpg"
  end

  # normalize the keys
  # ex: "OL893415W" becomes "/works/OL893415W"
  def self.normalize_work_key(key)
    match = WORK_KEY.match(key.to_s.strip)
    "/works/#{match[1]}" if match
  end

  def self.attributes_from_doc(doc)
    return if doc.nil? || doc["title"].blank?
    {
      open_library_key: normalize_work_key(doc["key"]),
      title: doc["title"],
      author: Array(doc["author_name"]).first.presence || "Unknown author",
      year: doc["first_publish_year"],
      page_count:       positive(doc["number_of_pages_median"]),
      genre:            Genre.classify(doc["subject"]),
      cover_id:         positive(doc["cover_i"])
    }
  end

  # fallback when the search index doesn't have the book yet: build it from the work record
  def self.attributes_from_work(details)
    author_key = Array(details["authors"]).filter_map { |entry| entry.dig("author", "key") }.first
    author     = author_key && get_json("#{author_key}.json")&.dig("name")

    {
      title:      details["title"],
      author:     author.presence || "Unknown author",
      year:       details["first_publish_date"].to_s[/\d{4}/]&.to_i,
      page_count: nil,
      genre:      Genre.classify(details["subjects"]),
      cover_id:   Array(details["covers"]).map(&:to_i).find(&:positive?)
    }
  end

  # The search document for one work key. Any problems are ignored because
  # attributes_from_work can stand in for it.
  def self.doc_for_key(key)
    docs(q: %(key:"#{key}"), limit: 1).first
  rescue Error
    nil
  end

  def self.clean_description(raw)
    text = raw.is_a?(Hash) ? raw["value"] : raw
    return if text.blank?

    text = text.to_s.split(/\r?\n-{3,}/).first.to_s
    text = text.gsub(/\(\[source\]\[\d+\]\)/i, "")
               .gsub(/^\s*\[\d+\]:\s*\S+\s*$/, "")
               .gsub(/\[([^\]]+)\]\[\d+\]/, '\1')
               .strip
    text.presence&.truncate(MAX_DESCRIPTION, separator: " ")
  end

  def self.positive(value)
    value.to_i if value.to_i.positive?
  end

  def self.docs(params)
    get_json("/search.json", params.merge(fields: FIELDS))&.fetch("docs", []) || []
  end

  # HTTP GET a path on openlibrary.org and parse the JSON. Return nil for 404.
  # follows one redirect
  def self.get_json(path, params = {}, redirects_left: 1)
    uri = URI.join(BASE, path)
    uri.query = URI.encode_www_form(params) if params.any?

    request  = Net::HTTP::Get.new(uri, "User-Agent" => USER_AGENT, "Accept" => "application/json")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
      http.request(request)
    end

    case response
    when Net::HTTPSuccess
      body = JSON.parse(response.body)
      # merged works answer 200
      if body.is_a?(Hash) && body.dig("type", "key") == "/type/redirect" && body["location"].present? && redirects_left.positive?
        return get_json("#{body["location"]}.json", redirects_left: redirects_left - 1)
      end
      body
    when Net::HTTPNotFound
      nil
    when Net::HTTPRedirection
      location = URI.join(BASE, response["location"].to_s)
      raise Error, "Open Library redirected too many times" unless redirects_left.positive? && location.host == uri.host
      get_json(location.request_uri, redirects_left: redirects_left - 1)
    else
      raise Error, "Open Library error: #{response.code}"
    end
  rescue *NETWORK_ERRORS, URI::InvalidURIError => e
    raise Error, "Open Library request failed (#{e.class})"
  end

  # make class methods private and inaccessible to other
  # parts of the application for encapsulation
  private_class_method :attributes_from_doc, :attributes_from_work, :doc_for_key, :clean_description, :positive, :docs, :get_json
end
