class CreateBackRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :back_records do |t|
      t.references :record
      t.string :debit
      t.string :credit
      t.integer :amount
      t.date :when

      t.timestamps
    end
  end
end
