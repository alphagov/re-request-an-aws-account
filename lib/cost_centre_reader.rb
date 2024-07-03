require 'csv'

class CostCentreReader
  attr_reader :data

  class CostCentre
    def initialize(csv_row)
      @csv_row = csv_row
    end

    def get(field)
      @csv_row[field]
    end

    def cost_centre_description
      get("Cost Centre Description")
    end

    def cost_centre_code
      get("Cost Centre")
    end

    def business_unit
      get("Level 04 Parent Descr")
    end

    def subsection
      get("Level 05 Parent Descr")
    end
  end

  def initialize(data)
    @data = CSV.parse(data, headers: true)
  end

  def get_by_cost_centre_code(cost_centre_code)
    found = @data.find {|row|
      row["Cost Centre"] == cost_centre_code
    }
    if found
      CostCentre.new(found)
    else
      nil
    end
  end
end
