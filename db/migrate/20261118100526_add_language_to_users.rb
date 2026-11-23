class AddLanguageToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :language, :string, default: 'en'
  end
end
