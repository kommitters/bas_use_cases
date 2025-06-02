# frozen_string_literal: true

Sequel.migration do
  up do
    create_table?(:observed_websites_conversations) do
      foreign_key :observed_website_id, :observed_websites, on_delete: :cascade
      foreign_key :conversation_id, :conversations, on_delete: :cascade
      primary_key %i[observed_website_id conversation_id]
    end
  end

  down do
    drop_table?(:observed_websites_conversations)
  end
end
