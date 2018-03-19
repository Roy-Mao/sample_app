class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    # Add an index will speed up the searching process
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # Why add a combined unique index? The answer is to prevent curl attack. This line of code will raise an error if a user tries to create dupliate relationships
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
