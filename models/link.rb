class Link < ActiveRecord::Base
  validates :title, format: { with: /\A[\s\u00c0-\u00ffA-Za-z0-9 \.,!?]{1,}\z/ }

  validates :href, format: { with: /(\A[\[a-z0-9\/]{1,}\z|\A\s\z)/ }

end
