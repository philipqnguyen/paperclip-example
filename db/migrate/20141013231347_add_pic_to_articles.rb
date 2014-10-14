class AddPicToArticles < ActiveRecord::Migration
  def self.up
    add_attachment :articles, :pic
  end

  def self.down
    remove_attachment :articles, :pic
  end
end
