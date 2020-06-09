class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :title, presence: true, length: { maximum: 250 }
  validates :content, presence: true
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png],
                                    message: "must be of a valid format (.jpeg, .gif, .png)" },
                    size: { less_than: 5.megabytes,
                            message: "size must be less than 5 MB" }

  # returns resized image for display
  def display_image
    image.variant(resize_to_limit: [500, 500])
  end
end
