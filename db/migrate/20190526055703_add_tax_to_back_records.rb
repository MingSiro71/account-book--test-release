class AddTaxToBackRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :back_records, :tax, :integer
  end
end
