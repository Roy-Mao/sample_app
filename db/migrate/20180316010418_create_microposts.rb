class CreateMicroposts < ActiveRecord::Migration[5.1]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, foreign_key: true

      t.timestamps
    end
    # Add this line, because we wanna retrieve all the microposts associated with a given user id in reverse order
    add_index :microposts, [:user_id, :created_at]
  end
end
