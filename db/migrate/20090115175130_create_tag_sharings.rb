class CreateTagSharings < ActiveRecord::Migration
  def self.up
    create_table :tag_sharings do |t|
      t.integer :user_id, :owner_id, :tag_id
      t.boolean :show_in_top
      t.string :style
    end
  end

  def self.down
    drop_table :tag_sharings
  end
end
