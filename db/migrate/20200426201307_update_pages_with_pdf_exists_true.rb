class UpdatePagesWithPdfExistsTrue < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("update pages set pdf_exists=true")
  end
end
