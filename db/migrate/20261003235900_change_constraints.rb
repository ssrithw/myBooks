class ChangeConstraints < ActiveRecord::Migration[8.1]
  def change
    change_column_null :books, :title, false
    change_column_null :books, :author, false
    change_column_null :users, :email, false
    change_column_null :users, :password_digest, false

    change_column_default :users, :is_admin, from: nil, to: false
    change_column_default :user_books, :is_public, from: nil, to: false
    change_column_default :user_books, :status, from: nil, to: "to_read"

    add_index :users, :email, unique: true
    add_index :books, [:title, :author], unique: true
    add_index :user_books, [:user_id, :book_id], unique: true
  end
end
