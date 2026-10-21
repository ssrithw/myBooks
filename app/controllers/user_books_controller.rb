# One user's shelf entry for one book. Every action works only on the logged-in user's own entries.
class UserBooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entry, only: %i[update destroy]

  # POST /user_books
  def create
    @entry = current_user.user_books.new(entry_params.merge(book_id: params.dig(:user_book, :book_id)))

    if @entry.save
      redirect_to @entry.book, notice: "Added to your shelf."
    else
      redirect_to(Book.find_by(id: @entry.book_id) || books_path, alert: @entry.errors.full_messages.to_sentence)
    end
  end

  # PATCH/PUT /user_books/1
  def update
    if @entry.update(entry_params)
      redirect_to @entry.book, notice: "Shelf entry saved.", status: :see_other
    else
      redirect_to @entry.book, alert: @entry.errors.full_messages.to_sentence, status: :see_other
    end
  end

  # DELETE /user_books/1
  def destroy
    @entry.destroy!
    redirect_to @entry.book, notice: "Removed from your shelf.", status: :see_other
  end

  private

  def set_entry
    @entry = current_user.user_books.find(params.expect(:id))
  end

  def entry_params
    params.expect(user_book: [ :status, :rating, :start, :finish, :is_public, :user_comment ])
  end
end
