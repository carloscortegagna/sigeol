class CreateBelongs < ActiveRecord::Migration
  def self.up
    create_table :belongs do |t|
      t.integer :teaching_id,:null=>false
      t.integer :curriculum_id,:null=>false
      t.boolean :isOptional
      t.timestamps
    end
      add_index(:belongs,[:curriculum_id,:teaching_id],:unique=>true)
  end

  def self.down
    remove_index :belongs,:column=>[:curriculum_id,:teaching_id]
    drop_table :belongs
  end
end
