# This controls the user profiles. Anyone can look at anyone else's profile
# but they are not allowed to change other users' info. Intended behaviour is
# that users/edit only grants access to your own profile.
class UsersController < ApplicationController
  # GET /readers
  # load all users sorted by username and get their public books
  def index
    @users = User.select("users.*, 
    (SELECT COUNT(*) FROM user_books ub WHERE ub.user_id = users.id AND ub.is_public) AS shared_count").order(:username)
  end

  # GET /readers/:username
  # public profiles
  def show
    @user = User.find_by!(username: params.expect(:id))
    @owner = current_user == @user

    # owners can set books to private such that only
    # they can see them
    base = @user.user_books
    base = base.shared unless @owner

    # book count used for the profile stats, grouped by
    # reading status
    @counts = base.group(:status).count
    # total no of books
    @total = @counts.values.sum
    # display status if the user has added the book to their shelf
    @status = params[:status] if UserBook.statuses.key?(params[:status].to_s)
    # shelf entries ordered by date descending
    @entries = (@status ? base.where(status: @status) : base).includes(:book).order(updated_at: :desc)
    # average rating
    @average_rating = base.where.not(rating: nil).average(:rating)&.to_f&.round(1)
    # call recommendation algorithm
    @picks = BookRecommender.new(@user, limit: 6).call if @owner
  end
end
