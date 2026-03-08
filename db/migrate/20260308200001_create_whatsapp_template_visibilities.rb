class CreateWhatsappTemplateVisibilities < ActiveRecord::Migration[7.0]
  def change
    create_table :whatsapp_template_visibilities do |t|
      t.bigint :account_id, null: false
      t.bigint :channel_whatsapp_id, null: false
      t.string :template_name, null: false
      t.string :template_language
      t.string :assignable_type, null: false
      t.bigint :assignable_id, null: false

      t.timestamps
    end

    add_index :whatsapp_template_visibilities, :account_id
    add_index :whatsapp_template_visibilities, :channel_whatsapp_id
    add_index :whatsapp_template_visibilities,
              [:channel_whatsapp_id, :template_name, :assignable_type, :assignable_id],
              unique: true,
              name: 'idx_template_visibility_unique'
    add_foreign_key :whatsapp_template_visibilities, :accounts
    add_foreign_key :whatsapp_template_visibilities, :channel_whatsapp
  end
end
