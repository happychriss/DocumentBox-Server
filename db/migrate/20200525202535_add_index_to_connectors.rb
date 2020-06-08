class AddIndexToConnectors < ActiveRecord::Migration[6.0]
  def change
    add_index :connectors, :service
  end
end
