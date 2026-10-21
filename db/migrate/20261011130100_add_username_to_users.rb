# Adds a unique, case-insensitive username. Existing accounts get one made from the
# part of their email before the @ (with a number added if that name is taken).
class AddUsernameToUsers < ActiveRecord::Migration[8.1]
  # Plain model so this migration doesn't depend on app/models/user.rb
  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    add_column :users, :username, :citext

    MigrationUser.reset_column_information
    taken = Set.new
    MigrationUser.order(:id).find_each do |user|
      base = user.email.to_s.split("@").first.to_s.downcase.gsub(/[^a-z0-9_]/, "_")[0, 16]
      base = "reader" if base.length < 3

      candidate = base
      suffix = 1
      while taken.include?(candidate)
        suffix += 1
        candidate = "#{base}#{suffix}"
      end

      taken << candidate
      user.update_columns(username: candidate)
    end

    change_column_null :users, :username, false
    add_index :users, :username, unique: true
  end

  def down
    remove_index :users, :username
    remove_column :users, :username
  end
end
