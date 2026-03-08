class CreateKanbanStages < ActiveRecord::Migration[7.0]
  def change
    create_table :kanban_stages do |t|
      t.bigint :account_id, null: false
      t.bigint :inbox_id, null: false
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.string :color
      t.boolean :is_default, default: false
      t.boolean :is_closed, default: false

      t.timestamps
    end

    add_index :kanban_stages, [:inbox_id, :position]
    add_index :kanban_stages, :account_id
    add_foreign_key :kanban_stages, :accounts
    add_foreign_key :kanban_stages, :inboxes
  end
end
