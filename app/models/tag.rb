class Tag < ActiveRecord::Base
 has_many :taggings, :dependent => :destroy
 default_scope { order(name: :asc) }
end
