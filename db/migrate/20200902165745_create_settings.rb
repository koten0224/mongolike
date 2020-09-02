class CreateSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :settings do |t|
      t.string :key
      t.string :value
      t.string :cls
      t.references :owner, polymorphic: true, null: false

      t.timestamps
    end
  end
end
