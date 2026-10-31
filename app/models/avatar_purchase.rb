# One avatar bought by one person, with the price paid at the time
class AvatarPurchase < ApplicationRecord
  belongs_to :user

  validates :avatar_key, presence: true, uniqueness: { scope: :user_id }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validate :avatar_exists

  private

  def avatar_exists
    errors.add(:avatar_key, :invalid) unless Avatar.keys.include?(avatar_key)
  end
end
