class ChangePdfExistsDefaultFalse < ActiveRecord::Migration

  def change
    change_column :pages, :pdf_exists, :boolean, :default =>false
  end

end
