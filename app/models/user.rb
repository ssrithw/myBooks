class User < ApplicationRecord
  # Devise handles sign up, log in/out, "remember me", password resets and the
  # account settings page.
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  USERNAME_FORMAT = /\A[a-z0-9_]{3,20}\z/

  has_many :user_books, dependent: :destroy
  has_many :books, through: :user_books

  normalizes :email,    with: ->(email) { email.strip.downcase }
  normalizes :username, with: ->(name) { name.strip.downcase }

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: USERNAME_FORMAT,
                                 message: "must be 3 to 20 characters: lowercase letters, numbers and underscores",
                                 allow_blank: true }
  validate :email_unchanged, on: :update

  # profile URLs use /readers/username
  def to_param
    username_was.presence || username
  end

  def admin?
    is_admin?
  end

  private

  def email_unchanged
    errors.add(:email, "can't be changed") if will_save_change_to_email?
  end
end
