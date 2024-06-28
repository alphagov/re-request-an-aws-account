class OrganisationSummaryController < ApplicationController
 
    def organisation_summary
        @answers = session.fetch('form', {}).with_indifferent_access
    end
  end