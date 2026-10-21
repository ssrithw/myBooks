class PagesController < ApplicationController
  def home
    # Books with covers are prioritized for the hero shelf
    ordered       = Book.order(Arel.sql("(cover_id IS NULL), created_at DESC"))
    @hero_books   = ordered.limit(5)
    @recent_books = ordered.limit(6)
    @picks        = BookRecommender.new(current_user, limit: 6).call if user_signed_in?
  end
end
