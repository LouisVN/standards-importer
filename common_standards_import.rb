require 'active_record'
require 'logger'
require_relative 'common_standards_whitelist'

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

  def self.run(jurisdictions_file, standards_file, whitelist_file, wipe_existing=false)
    ensure_setup
    importer = self.new
    importer.import_jurisdictions(jurisdictions_file, whitelist_file)
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

  def import_jurisdictions(file, whitelist_file)
    jurisdictions = JSON.parse(File.read(file))
    whitelist = CommonStandardsWhitelist.parse(whitelist_file)
    jurisdictions.each do |jur| 
      if whitelist.any? { |jurisdiction| jurisdiction.include? jur['title'] }
	    begin
          Jurisdiction.create(
            title: jur["title"],
            csp_id: jur["id"],
            type: jur["type"],
            document: jur
          )
		rescue ActiveRecord::RecordNotUnique => e
		  #update entry if needed
		  old_jurisdiction = Jurisdiction.where(csp_id: jur["id"]).first
          Jurisdiction.update(
		    old_jurisdiction.id,
            :title => jur["title"],
            :csp_id => jur["id"],
            :type => jur["type"],
            :document => jur
          )		
		end
      end
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
        #raise "Jurisdiction not found for #{set["id"]} #{set["title"]}"
        next
      end
	  
	  begin
        #create root standard
        root = Standard.create(
          jurisdiction_id: jurisdiction.id,
          csp_id: set["id"],
          title: set["title"],
          subject: subject,
          document: set
        )
		
		create_education_level(root, ed_levels)
	  rescue ActiveRecord::RecordNotUnique => e
		#update entry if needed
	    old_standard = Standard.where(csp_id: set["id"]).first
	    root = Standard.update(
          old_standard.id,
          :csp_id => set["id"],
          :title => set["title"],
          :subject => subject,
          :document => set
        )
		
		#delete and recreate related concepts
		@id = root.id
	    EducationLevel.delete_all "standard_id = #{@id}"
	    create_education_level(root, ed_levels)
	  end
	
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

  def create_children_standards(standard, jurisdiction, ed_levels, subject, parent_ids)
    indexed = true
    if standard["statementLevel"]
      indexed = standard["statementLevel"] == "Standard"
    elsif standard["depth"] == 0
      indexed = false
    end
	
	begin 
	  #create child standard and related concepts
	  child = Standard.create(
		jurisdiction_id: jurisdiction.id,
		csp_id: standard["id"],
		subject: subject,
		document: standard,
		indexed: indexed
	  )
	  
	  create_education_level(child, ed_levels)
	  create_parent_standards(child, parent_ids)

    rescue ActiveRecord::RecordNotUnique => e
	  #update entry if needed
	  old_standard = Standard.where(csp_id: standard["id"]).first
	  child = Standard.update(
        old_standard.id,
        :csp_id => standard["id"],
        :subject => subject,
        :document => standard,
        :indexed => indexed
      )
	  #delete and recreate related concepts
	  @id = old_standard.id
	  EducationLevel.delete_all "standard_id = #{@id}"
	  create_education_level(child, ed_levels)

	  Standard_Standard.delete_all "child_id = #{@id}"
	  create_parent_standards(child, parent_ids)
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
  
  def create_parent_standards(standard, parent_ids)
	parent_ids.each do |parent_id|
      Standard_Standard.create(
        parent_id: parent_id,
        child_id: standard.id
      )
    end 
  end 
end