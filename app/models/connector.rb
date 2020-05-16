# Connection stores the DRB connection information, that is used to call remote objects like scanner / converter
# see lib ServiceConnector.rb

class Connector < ActiveRecord::Base

  validates_uniqueness_of :uid

  def self.find_service(service)
    Connector.where(service: service).order("prio desc").first # high prio, high number -> highest prio first
  end

end
