class ServiceController < ApplicationController
  def service
    @form = ServiceForm.new(session.fetch('form', {}))
  end

  def post
    form_params = params.fetch(
      'service_form',
      {}
    ).permit(
      :service_name,
      :service_is_out_of_hours_support_provided
    ).to_h
    @form = ServiceForm.new(form_params)
    return render :service if @form.invalid?

    session['form'] = session.fetch('form', {}).merge form_params

    redirect_to @form.service_is_out_of_hours_support_provided == 'true' ?
      out_of_hours_support_path :
      security_path
  end
end
