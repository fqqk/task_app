class Comment < ApplicationRecord
  paginates_per 5
  belongs_to :user
  belongs_to :task
  validates :comment, presence: true
end
