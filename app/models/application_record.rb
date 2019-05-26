class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.tax_rates
    [0, 8, 10]
  end

end
