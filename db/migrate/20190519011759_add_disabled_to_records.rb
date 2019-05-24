class AddDisabledToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :disabled, :datetime
  end
end
