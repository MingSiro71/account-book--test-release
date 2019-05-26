class AddTaxToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :tax, :integer
  end
end
