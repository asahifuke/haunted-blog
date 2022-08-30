# frozen_string_literal: true

class Blog < ApplicationRecord
  before_save :cannot_set_up_random_eyecatch_if_not_premium

  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true

  scope :published, -> { where('secret = FALSE') }

  scope :search, lambda { |term|
    where('title LIKE ? OR content LIKE ?', "%#{term}%", "%#{term}%")
  }

  scope :default_order, -> { order(id: :desc) }

  def owned_by?(target_user)
    user == target_user
  end

  private

  def cannot_set_up_random_eyecatch_if_not_premium
    self.random_eyecatch = false unless user.premium
  end
end
