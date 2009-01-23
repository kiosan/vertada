class AddClientToIdea < ActiveRecord::Migration
  def self.up
    add_column :ideas, :client, :string, :default => "web"
  end

  def self.down
  end
end
