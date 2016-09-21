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
	
    create_table :parents do |t|
	end

	create_join_table :standards, :parents
	
	create_table :education_levels do |t|
		t.string :name
	end
	
	create_join_table :standards, :education_levels
	
  end
end
