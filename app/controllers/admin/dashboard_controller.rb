module Admin
  class DashboardController < BaseController
    def index
      # used to display the quick stats on the admin dashboard
      @stats = {readers: User.count, books: Book.count, shelf_entries: UserBook.count, missing_covers: Book.without_cover.count}  
      @users = User.left_joins(:user_books).group(:id).select("users.*, COUNT(user_books.id) AS shelf_count").order(:created_at)
      @books = Book.left_joins(:user_books).group(:id).select("books.*, COUNT(user_books.id) AS shelf_count").order(:title)
      @activity = UserBook.includes(:user, :book).order(updated_at: :desc).limit(8)
    end
  end
end
