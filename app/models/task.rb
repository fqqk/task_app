class Task < ApplicationRecord
  belongs_to :user
  enum status: { incomplete: 0, doing: 1, complete: 2 }
end
