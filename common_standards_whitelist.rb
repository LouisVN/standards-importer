require 'logger'
require 'csv'

class CommonStandardsWhitelist
  def self.parse(filename)
    arr = CSV.read(filename)
    return arr 
  end
end
