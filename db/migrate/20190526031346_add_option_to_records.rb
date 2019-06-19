class AddOptionToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :option, :string
  end
end
