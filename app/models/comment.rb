class Comment < ApplicationRecord
  paginates_per 5
  belongs_to :user
  belongs_to :task
  validates :comment, presence: true, length: { maximum: 140 }
end
