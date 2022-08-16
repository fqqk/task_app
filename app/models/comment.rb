class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :task
  paginates_per 5
  validates :comment, presence: true
end
