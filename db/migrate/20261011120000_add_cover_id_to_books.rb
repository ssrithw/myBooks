# Open Library's internal cover id. Covers are hot-linked from covers.openlibrary.org
# using this id, so no image files are stored in the app.
class AddCoverIdToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :cover_id, :integer
  end
end
