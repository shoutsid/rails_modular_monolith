class AddTitleAndDescriptionToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :ollama_conversations, :title, :string
    add_column :ollama_conversations, :description, :text
  end
end
