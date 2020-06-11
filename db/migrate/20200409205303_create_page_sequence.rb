class CreatePageSequence < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute("create SEQUENCE pages_fid_seq")
    end
  def down
    ActiveRecord::Base.connection.execute("drop SEQUENCE pages_fid_seq")
  end
end
