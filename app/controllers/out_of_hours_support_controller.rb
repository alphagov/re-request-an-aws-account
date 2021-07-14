class OutOfHoursSupportController < ApplicationController
  def out_of_hours_support
    @form = OutOfHoursSupportForm.new(session.fetch('form', {}))
  end

  def post
    form_params = params.fetch(
      'out_of_hours_support_form',
      {}
    ).permit(
      :out_of_hours_support_contact_name,
      :out_of_hours_support_phone_number,
      :out_of_hours_support_pagerduty_link,
      :out_of_hours_support_email_address
    ).to_h

    @form = OutOfHoursSupportForm.new(form_params)
    return render :out_of_hours_support if @form.invalid?

    session['form'] = session.fetch('form', {}).merge form_params

    redirect_to security_path
  end
end
