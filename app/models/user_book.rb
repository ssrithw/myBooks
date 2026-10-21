class UserBook < ApplicationRecord
  RATING_RANGE = 1..5
  RATEABLE_STATUSES = %w[finished abandoned].freeze   # users may only rate books they've finished or abandoned
  MAX_COMMENT_LENGTH = 500
  STATUS_LABELS = {
    "to_read" => "To read",
    "reading" => "Reading",
    "finished" => "Finished",
    "abandoned" => "Abandoned"
  }.freeze

  belongs_to :user
  belongs_to :book

  enum :status, { to_read: "to_read", reading: "reading", finished: "finished", abandoned: "abandoned" }, validate: true

  scope :shared, -> { where(is_public: true) }

  validates :book_id, uniqueness: { scope: :user_id, message: "is already on your shelf!" }
  validates :rating, numericality: { only_integer: true, in: RATING_RANGE }, allow_nil: true
  validates :user_comment, length: { maximum: MAX_COMMENT_LENGTH }
  validate  :finish_not_before_start
  validate  :rating_only_when_rateable

  before_validation :fill_dates_from_status
  before_validation :clear_rating_when_unrateable

  def rateable?
    status.to_s.in?(RATEABLE_STATUSES)
  end

  def status_label
    STATUS_LABELS.fetch(status.to_s, status.to_s.humanize)
  end

  private

  # if a date wasn't entered, add today's date
  def fill_dates_from_status
    return unless status_changed?

    self.start  ||= Date.current if reading? || finished?
    self.finish ||= Date.current if finished?
    
  end

  # clear rating if a book's status changes from read/abandoned to tbr/reading
  def clear_rating_when_unrateable
    self.rating = nil if status_changed? && !rateable? && !rating_changed? 
  end

  def rating_only_when_rateable
    return if rating.nil? || rateable?
    errors.add(:rating, "can only be given once you've finished or abandoned the book")
  end

  # stop finish dates from being earlier than start
  def finish_not_before_start
    return if start.blank? || finish.blank?
    errors.add(:finish, "can't be before the start date") if finish < start
  end
end
