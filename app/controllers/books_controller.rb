class BooksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :require_admin, except: %i[index show]
  before_action :set_book, only: %i[show edit update destroy] # load @book early

  # GET /books
  def index
    @query = params[:q].to_s.strip
    @books = Book.search(@query).order(:title)
  end

  # GET /books/1
  def show
    # no. of readers with this book on their shelf
    @shelf_count = @book.user_books.count 
    # average calculated by the method in the Book model
    @average_rating = @book.average_rating 
    # shelf entry - skips if not logged in, generates new one if user doesn't have an entry
    @entry = current_user&.user_books&.find_by(book: @book) || UserBook.new(book: @book)
    # load up to 10 user notes sorted by descending date
    @notes = @book.user_books.shared.where.not(user_comment: [ nil, "" ]).includes(:user).order(updated_at: :desc).limit(10)
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: "Successfully added your book!"
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /books/1
  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Successfully updated your book!", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /books/1
  def destroy
    @book.destroy!
    redirect_to books_path, notice: "Successfully deleted your book!", status: :see_other
  end

  private

  def set_book
    @book = Book.find(params.expect(:id))
  end

  def book_params
    params.expect(book: [ :title, :author, :genre, :description, :year, :page_count, :cover_id ])
  end
end
