class CreateFeeds < ActiveRecord::Migration
  def up
    create_table :feeds do |t|
      t.string :title
      t.text :content
      t.boolean :is_deleted
      t.timestamps
    end
    Feed.create(title: 'Üdvözöllek az oldalon', content: 'Ezennel az oldal megkezdte a működését.', is_deleted: false)
  end
  def down
    drop_table :feeds
  end
end
