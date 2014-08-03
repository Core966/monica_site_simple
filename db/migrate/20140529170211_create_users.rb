class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password_hash
      t.string :password_salt
      t.boolean :is_deleted
      t.timestamps
    end
    User.create(username: "adminer", email: "example@example.com", password: "Admin12345", is_deleted: false)
  end
  def down
    drop_table :users
  end
end
