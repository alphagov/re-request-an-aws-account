class IndexController < ApplicationController
  def index()
    @form = RequestAnAwsAccountForm.new({})
  end

  def post()
    @form = RequestAnAwsAccountForm.new(params)
  end
end