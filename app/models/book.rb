class Book < ApplicationRecord
  OPEN_LIBRARY_KEY_FORMAT = %r{\A/works/OL\d+W\z}

  has_many :user_books, dependent: :destroy
  has_many :users, through: :user_books

  validates :author, presence: true
  validates :title, presence: true, uniqueness: { scope: :author }
  validates :page_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :year, numericality: { only_integer: true }, allow_nil: true
  validates :cover_id, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :open_library_key, format: { with: OPEN_LIBRARY_KEY_FORMAT }, uniqueness: true, allow_nil: true

  normalizes :genre, with: ->(genre) { genre.strip.presence }

  attr_accessor :skip_cover_fetch

  # used to call the fetch cover job
  after_create_commit :enqueue_cover_fetch

  scope :without_cover, -> { where(cover_id: nil) }

  # define as a class method, self is used in case the Book class is ever renamed
  def self.search(term)
    return all if term.blank?
    # case-insensitive search for author, title or genre
    pattern = "%#{sanitize_sql_like(term.to_s.strip)}%"
    where("title ILIKE :p OR author ILIKE :p OR genre ILIKE :p", p: pattern)
  end

  # cover image URL on covers.openlibrary.org, or nil when the book has no cover id
  def cover_url(size = "M")
    OpenLibraryClient.cover_url(cover_id, size: size)
  end

  def open_library_url
    "#{OpenLibraryClient::BASE}#{open_library_key}" if open_library_key.present?
  end

  # finds the cover on OpenLibrary and saves it. Returns the cover id, or nil if none was found.
  # Raises OpenLibraryClient::Error if the API cannot be reached.
  def fetch_cover!
    found = OpenLibraryClient.find_cover_id(title, author)
    update!(cover_id: found) if found
    found
  end

  # calculate the average rating over all user reviews
  def average_rating
    user_books.where.not(rating: nil).average(:rating)&.to_f&.round(1)
  end

  private

  # queue the book cover fetch job
  def enqueue_cover_fetch
    FetchCoverJob.perform_later(id) if cover_id.blank? && !skip_cover_fetch
  end
end
