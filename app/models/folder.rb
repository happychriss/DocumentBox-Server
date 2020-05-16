class Folder < ActiveRecord::Base

  MIGRATION_FOLDER = 9999


  has_many :documents
  has_many :covers
  default_scope { order(:name) }

end
