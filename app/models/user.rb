class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable #:confirmableを追記
  has_many :tasks, dependent: :destroy
end
