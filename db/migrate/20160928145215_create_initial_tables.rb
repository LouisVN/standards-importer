class CreateInitialTables < ActiveRecord::Migration
  def change
    create_table :Jurisdiction do |t|
      t.column :csp_id, :string
      t.column :document, :text
      t.string :title
      t.string :type
    end

    add_index :Jurisdiction, :csp_id

    create_table :Standard do |t|
      t.column :jurisdiction_id, :integer, null: false
      t.column :csp_id, :string
      t.string :title
      t.string :subject
      t.column :document, :text
      t.column :indexed, :boolean, null:false, default: false
      t.column :child_count, :integer, default: 0
      t.foreign_key :Jurisdiction
    end
	
    add_index :Standard, :jurisdiction_id
    add_index :Standard, :csp_id
	
    create_table :EducationLevel, {:id => false} do |t|
      t.integer :standard_id
      t.string :education_level, :limit => 50
      t.foreign_key :Standard
    end

    add_index :EducationLevel, :standard_id
    execute "ALTER TABLE EducationLevel ADD PRIMARY KEY (standard_id,education_level);"
 
    create_table :Standard_Standard, {:id => false} do |t|
      t.integer :parent_id
      t.integer :child_id 
    end
    
    add_index :Standard_Standard, :parent_id
    add_index :Standard_Standard, :child_id
    add_foreign_key :Standard_Standard, :Standard, column: :parent_id, primary_key: "id"
    add_foreign_key :Standard_Standard, :Standard, column: :child_id, primary_key: "id"
    execute "ALTER TABLE Standard_Standard ADD PRIMARY KEY (parent_id,child_id);"
  end
end
