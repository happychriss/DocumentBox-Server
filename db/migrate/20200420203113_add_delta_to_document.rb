class AddDeltaToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :delta, :boolean, :default => true,
               :null => false
    add_index :documents, :delta
  end
end
