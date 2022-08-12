class Task < ApplicationRecord
  belongs_to :user
  enum status: { incomplete: 0, doing: 1, complete: 2 }
  paginates_per 6
  validates :title, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :deadline, presence: true
  validates :status, presence: true

  scope :latest, -> {order(updated_at: :desc)}
  scope :old, -> {order(updated_at: :asc)}
  scope :emergency, -> {order(deadline: :asc)}
end
