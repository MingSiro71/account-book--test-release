class AddDivisionIdToBackRecords < ActiveRecord::Migration[5.2]
  def change
    add_reference :back_records, :division, foreign_key: true
  end
end
