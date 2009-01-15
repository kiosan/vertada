class CreateFsFiles < ActiveRecord::Migration
  def self.up
    create_table :fs_files do |t|
      t.string :file_name, :content_type, :type
      t.integer :size, :uploader_id, :idea_id
      t.binary :content, :limit=>10240000
      t.timestamps
    end
  end

  def self.down
    drop_table :fs_files
  end
end