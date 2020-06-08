class AddIndexesToPage < ActiveRecord::Migration[6.0]
  def change
  add_index :pages,:ocr
  add_index :pages,:status
  add_index :pages, :backup
  add_index :pages, :document_id
  end
end
