require 'active_record'
require 'logger'

class Jurisdiction < ActiveRecord::Base
  self.table_name = "Jurisdiction"
  self.inheritance_column = :_type_disabled
  has_many :Standard
end

class Standard < ActiveRecord::Base
  self.table_name = "Standard"
end

class Standard_Standard < ActiveRecord::Base
  self.table_name = "Standard_Standard"
end

class EducationLevel < ActiveRecord::Base
  self.table_name = "EducationLevel"
end

class CommonStandardsImport

  def self.run(jurisdictions_file, standards_file, wipe_existing=false)
    ensure_setup
    importer = self.new
    importer.import_jurisdictions(jurisdictions_file)
    importer.import_standards(standards_file)
  end

  def self.initial_setup
    ActiveRecord::Base.logger = Logger.new('debug.log')
    configuration = YAML::load(IO.read('db/config.yml'))
    ActiveRecord::Base.establish_connection(configuration[ENV["ENV"]])
  end

  def self.ensure_setup
    unless @is_setup
      initial_setup
      @is_setup = true
    end
  end

  def self.count_children
    ensure_setup
    @StandardTBL = Standard.table_name
	@ChildrenTBL = Standard_Standard.table_name
	ActiveRecord::Base.connection.execute("UPDATE #{@StandardTBL} as st SET st.child_count = (SELECT COUNT(*) FROM #{@ChildrenTBL} as ch WHERE ch.parent_id = st.id)")	
  end

  def import_jurisdictions(file)
    jurisdictions = JSON.parse(File.read(file))
    jurisdictions.each do |jur|
      Jurisdiction.create(
        title: jur["title"],
        csp_id: jur["id"],
        type: jur["type"],
        document: jur
      )
    end
  end

  def import_standards(file)
    standard_sets = JSON.parse(File.read(file))

    standard_sets.each do |set|
      ed_levels = set["educationLevels"]
      subject = set["subject"]
      child_standards = set.delete("standards")
      jurisdiction = Jurisdiction.where(csp_id: set["jurisdiction"]["id"]).first
      unless jurisdiction
        raise "Jurisdiction not found for #{set["id"]} #{set["title"]}"
      end
      #create root standard
      root = Standard.create(
        jurisdiction_id: jurisdiction.id,
        csp_id: set["id"],
        title: set["title"],
        subject: subject,
        document: set
      )
	  
	  create_education_level(root, ed_levels)
 
      sorted_standards = child_standards.values.sort {|x,y| x["depth"] <=> y["depth"]}

      sorted_standards.each do |standard|
        most_parents = Standard.where(csp_id: standard["ancestorIds"])
        parent_ids = [root.id] + most_parents.map(&:id)
        if parent_ids.length < standard["ancestorIds"].length + 1
          raise "parent not found"
        else
          create_children_standards(standard, jurisdiction, ed_levels, subject, parent_ids)
        end
      end
    end
  end
  
  def create_education_level(standard, ed_levels)
	ed_levels.each do |education_level|
      EducationLevel.create(
        standard_id: standard.id,
        education_level: education_level
      )
	end
  end

  def create_children_standards(standard, jurisdiction, ed_levels, subject, parent_ids)
    indexed = true
    if standard["statementLevel"]
      indexed = standard["statementLevel"] == "Standard"
    elsif standard["depth"] == 0
      indexed = false
    end

	parent_ids.each do |parent_id|
      child = Standard.create(
        jurisdiction_id: jurisdiction.id,
        csp_id: standard["id"],
        subject: subject,
        document: standard,
        indexed: indexed
      )
	  
	  create_education_level(child, ed_levels)

	  Standard_Standard.create(
        parent_id: parent_id,
        child_id: child.id
      )
	end
  end

end