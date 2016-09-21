class CreateInitialTables < ActiveRecord::Migration
  def change
    create_table :jurisdictions do |t|
      t.column :csp_id, :string
      t.column :document, :string
      t.string :title
      t.string :type
    end

    add_index :jurisdictions, :csp_id

    create_table :standards do |t|
      t.column :jurisdiction_id, :integer, null: false
      t.column :csp_id, :string
      t.string :title
      t.string :subject
      t.column :document, :string
      t.column :indexed, :boolean, null:false, default: false
      t.column :child_count, :integer, default: 0
      t.foreign_key :jurisdictions
    end
	
    add_index :standards, :jurisdiction_id
    add_index :standards, :csp_id
	
    create_table :standards_education_levels, {:id => false} do |t|
      t.integer :standard_id
      t.string :education_level
      t.foreign_key :standards
    end

    add_index :standards_education_levels, :standard_id
    execute "ALTER TABLE standards_education_levels ADD PRIMARY KEY (standard_id,education_level);"
 
    create_table :standards_standards, {:id => false} do |t|
      t.integer :parent_id
      t.integer :child_id 
    end
    
    add_index :standards_standards, :parent_id
    add_index :standards_standards, :child_id
    add_foreign_key :standards_standards, :standards, column: :parent_id, primary_key: "id"
    add_foreign_key :standards_standards, :standards, column: :child_id, primary_key: "id"
    execute "ALTER TABLE standards_standards ADD PRIMARY KEY (parent_id,child_id);"
  end
end
