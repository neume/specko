class User < ApplicationRecord
  include SuperModule
  enum user_status: [:active, :blocked]
  has_secure_password
  mount_uploader :file, FileUploader
  belongs_to :group
  validates :email, presence: 1
  validates :email, uniqueness: { scope: [:status, :group]}, if: :active?
end
