class CreateRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :records do |t|
      t.references :user, foreign_key: true
      t.references :division, foreign_key: true
      t.integer :amount
      t.date :when
      t.string :where
      t.string :where_from
      t.integer :quantity

      t.timestamps
    end
  end
end
