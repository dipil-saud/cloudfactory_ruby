module CF
  class Department
    include Client

    # Id of the specific Category
    attr_accessor :department_id 
    
    # Category name 
    attr_accessor :name
    
    # ==Returns all Department
    # ===Usage example
    #   categories = CF::Department.all
    def self.all
      response = get("/departments.json")
    end
    
    # Returns all lines of a specific Department
    def self.get_lines_of_department(department_id)
      @department_id = department_id
      get("/departments/#{@department_id}/lines.json")
    end
  end
end
