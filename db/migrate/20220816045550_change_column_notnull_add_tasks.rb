class ChangeColumnNotnullAddTasks < ActiveRecord::Migration[6.0]
  def change
    change_column :tasks, :status, :string, null: false, default: "incomplete"
  end
end
