# Moves authentication to Devise.
#
# has_secure_password and Devise both store bcrypt hashes, so password_digest is renamed
# rather than dropped: every existing account keeps its password.
# The sessions table came from the Rails 8 auth generator and was never used by the app.
class SwitchUsersToDevise < ActiveRecord::Migration[8.1]
  def up
    rename_column :users, :password_digest, :encrypted_password
    change_column_default :users, :encrypted_password, from: nil, to: ""

    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :remember_created_at, :datetime
    add_index :users, :reset_password_token, unique: true

    drop_table :sessions, if_exists: true
  end

  def down
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end

    remove_index :users, :reset_password_token
    remove_column :users, :remember_created_at
    remove_column :users, :reset_password_sent_at
    remove_column :users, :reset_password_token

    change_column_default :users, :encrypted_password, from: "", to: nil
    rename_column :users, :encrypted_password, :password_digest
  end
end
