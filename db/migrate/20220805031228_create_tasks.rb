class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.datetime :deadline, null: false
      t.references :tasks, :user, index: true, foreign_key: true
      t.integer :status, default: 0, null: false
      t.timestamps
    end
  end
end
