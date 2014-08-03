class CreateLinks < ActiveRecord::Migration
  def up
    create_table :links do |t|
      t.string :title
      t.string :href
      t.timestamps
    end
    Link.create(title: 'Példa1', href: "/blog/1")
    Link.create(title: 'Példa2', href: " ")
    Link.create(title: 'Példa3', href: " ")
    Link.create(title: 'Példa4', href: " ")
    Link.create(title: 'Példa5', href: " ")
  end
  def down
    drop_table :links
  end
end
