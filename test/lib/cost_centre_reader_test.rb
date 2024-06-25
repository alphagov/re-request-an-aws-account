require 'test_helper'
require "cost_centre_reader"

class CostCentreReaderTest < ActiveSupport::TestCase
  test 'we can read a cost centre CSV file' do
    fixture_file = File.dirname(__FILE__) + "/../fixtures/cost_centre_fixture.csv"
    cost_centres = CostCentreReader.new(fixture_file)
    
    cost_centre = cost_centres.get_by_cost_centre_code("12345678")

    assert cost_centre != nil
    assert_equal "BOOM", cost_centre.cost_centre_description
    assert_equal "12345678", cost_centre.cost_centre_code
    assert_equal "BING", cost_centre.business_unit
    assert_equal "BAZ", cost_centre.sub_section
  end

  test 'we return nil if no matching cost centre' do
    fixture_file = File.dirname(__FILE__) + "/../fixtures/cost_centre_fixture.csv"
    cost_centres = CostCentreReader.new(fixture_file)

    non_extant_code = "999999"
    cost_centre = cost_centres.get_by_cost_centre_code(non_extant_code)
    
    assert_nil cost_centre
  end
end