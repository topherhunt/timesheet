class CreateProjectHierarchies < ActiveRecord::Migration
  def change
    create_table :project_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :project_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "project_anc_desc_idx"

    add_index :project_hierarchies, [:descendant_id],
      name: "project_desc_idx"
  end
end
