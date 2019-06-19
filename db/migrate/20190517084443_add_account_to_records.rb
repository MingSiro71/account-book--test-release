class AddAccountToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :account_id, :bigint
  end
end
