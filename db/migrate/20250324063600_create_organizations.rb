class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.text :features
      t.text :quotas

      t.timestamps
    end
  end
end
