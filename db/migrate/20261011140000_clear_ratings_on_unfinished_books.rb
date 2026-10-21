# Ratings are now only allowed on finished or abandoned books.
# Removes any rating already saved on a "to read" or "reading" entry.
class ClearRatingsOnUnfinishedBooks < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE user_books SET rating = NULL
      WHERE rating IS NOT NULL AND status IN ('to_read', 'reading')
    SQL
  end

  def down
    # The removed ratings can't be restored
  end
end
