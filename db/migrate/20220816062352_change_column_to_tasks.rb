class ChangeColumnToTasks < ActiveRecord::Migration[6.0]
  def change
    change_column_null :tasks, :status, false, "incomplete"
    change_column :tasks, :status, :string, default: "incomplete"
  end
end
