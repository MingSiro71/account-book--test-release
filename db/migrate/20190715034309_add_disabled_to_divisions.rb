class AddDisabledToDivisions < ActiveRecord::Migration[5.2]
  def change
    add_column :divisions, :disabled, :datetime
  end
end
