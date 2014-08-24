class Post < ActiveRecord::Base
  validates :title, format: { with: /\A[\s\p{L}0-9\.,!?]{1,}\z/ }

  validates :body, format: { with: /\A[\s\p{L}0-9\.,!?\]\[\/:=]{1,}\Z/ }

  validates :is_deleted, format: { with: /\Atrue\z/ }, on: :update
end

