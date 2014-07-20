class Link < ActiveRecord::Base
  validates :title, format: { with: /\A[\s\p{L}0-9 \.,!?]{1,}\z/ }

  validates :href, format: { with: /\A[\[a-z0-9\/]{1,}\z/ }

end
