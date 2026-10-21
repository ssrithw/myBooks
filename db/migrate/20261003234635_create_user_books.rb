class CreateUserBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :user_books do |t|
      t.string :status
      t.integer :rating
      t.date :start
      t.date :finish
      t.boolean :is_public
      t.text :user_comment
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end
  end
end
