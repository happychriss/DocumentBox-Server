class ChangePdfExistsToPages < ActiveRecord::Migration

  def change
    change_column :pages, :pdf_exists, :boolean, :default =>true
  end


end
