class AddPdfExistsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :pdf_exists, :boolean, :default =>false
  end
end
