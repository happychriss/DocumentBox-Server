class PinnedDocument < ActiveRecord::Base
  belongs_to :document
  default_scope { order(id: :desc) }
end