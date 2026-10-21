# The Open Library work key (e.g. "/works/OL893415W") of books added from search,
# so the same work can't be imported twice.
class AddOpenLibraryKeyToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :open_library_key, :string
    add_index :books, :open_library_key, unique: true
  end
end
