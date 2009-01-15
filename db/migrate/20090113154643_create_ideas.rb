class CreateIdeas < ActiveRecord::Migration
  def self.up
    create_table :ideas do |t|
      t.text :body
      t.string :tags
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :ideas
  end
end
