class CreatePinnedDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :pinned_documents do |t|
      t.belongs_to :document
      t.timestamps
    end
  end
end
