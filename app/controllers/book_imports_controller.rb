# This is used to add books by searching the Open Library.
# Logged-in readers can add books.
# Alternatively, admins can type in the books.
class BookImportsController < ApplicationController
  before_action :authenticate_user!
  rate_limit to: 20, within: 1.minute, only: :create,
             with: -> { redirect_to new_book_import_path, alert: "You're adding books very quickly. Wait a minute and try again." }

  # GET /books/add
  # used to search open library and display results
  def new
    @query   = params[:q].to_s.strip.first(200)
    @results = []
    return if @query.blank?

    @results  = OpenLibraryClient.search(@query, limit: 20)
    @existing = Book.where(open_library_key: @results.filter_map { |result| result[:open_library_key] })
                    .index_by(&:open_library_key)
  rescue OpenLibraryClient::Error
    @error = "Open Library isn't answering right now. Try again in a minute."
  end

  # POST /books/add
  # add the selected book to the myBooks catalogue
  def create
    key = OpenLibraryClient.normalize_work_key(params[:key])
    return back_to_search(alert: "Not available through the Open Library.") unless key

    if (book = Book.find_by(open_library_key: key))
      return redirect_to(book, notice: "#{book.title} is already in our catalogue!", status: :see_other)
    end

    attrs = OpenLibraryClient.work(key)
    return back_to_search(alert: "Sorry, that book isn't available on the Open Library.") unless attrs

    book = Book.find_by(title: attrs[:title], author: attrs[:author])
    if book
      # Typed in by hand earlier: link it to Open Library instead of adding a copy
      book.update(open_library_key: key) if book.open_library_key.nil?
      return redirect_to(book, notice: "#{book.title} is already in the catalogue.", status: :see_other)
    end

    book = Book.new(attrs.slice(:open_library_key, :title, :author, :genre, :description, :year, :page_count, :cover_id))
    if book.save
      redirect_to book, notice: "#{book.title} was added to the catalogue. Put it on your shelf below.", status: :see_other
    else
      back_to_search(alert: "#{attrs[:title]} couldn't be added: #{book.errors.full_messages.to_sentence}.")
    end

  # catch error if someone else adds the same book  
  rescue ActiveRecord::RecordNotUnique
    book = Book.find_by(open_library_key: key) || Book.find_by(title: attrs&.dig(:title), author: attrs&.dig(:author))
    book ? redirect_to(book, status: :see_other) : back_to_search(alert: "Couldn't add this book. Try again later!")
  
  # OL not responding  
  rescue OpenLibraryClient::Error
    back_to_search(alert: "Open Library isn't responding right now. Try again later!")
  end

  private

  def back_to_search(alert:)
    redirect_to new_book_import_path(q: params[:q].presence), alert: alert, status: :see_other
  end
end
