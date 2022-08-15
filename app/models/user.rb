class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  has_many :tasks, dependent: :destroy
  has_many :comments, dependent: :destroy
  validates :name, presence: true
end
