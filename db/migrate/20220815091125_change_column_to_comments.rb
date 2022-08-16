class ChangeColumnToComments < ActiveRecord::Migration[6.0]
  def change
    change_column :comments, :comment, :text, null: false
  end
end
