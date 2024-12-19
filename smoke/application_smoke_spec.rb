require_relative 'smoke_helper'

RSpec.describe 'Application Smoke Tests' do
 describe 'Basic application health' do
   it 'returns 200 OK for the root path' do
     visit '/'
     expect(page.status_code).to eq(200)
   end
 end
end
