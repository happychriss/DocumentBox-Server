class RemoveDeltaFromPages < ActiveRecord::Migration
  remove_column :pages, :delta
end
