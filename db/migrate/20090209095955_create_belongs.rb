class CreateBelongs < ActiveRecord::Migration
  def self.up
    create_table :belongs do |t|
      t.integer :teaching_id
      t.integer :curriculum_id
      t.boolean :isOptional
      t.timestamps
    end
  end

  def self.down
    drop_table :belongs
  end
end
