class FetchCoverJob < ApplicationJob
  # job to fetch a book cover in the background
  # while other things load.
  # concurrent by design but not necessarily parallel

  queue_as :default

  retry_on OpenLibraryClient::Error, wait: 1.minute, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(book_id)
    book = Book.find(book_id)
    return if book.cover_id.present?

    book.fetch_cover!
  end
end
