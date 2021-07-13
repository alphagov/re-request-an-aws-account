class SecurityController < ApplicationController
  def security
    @form = SecurityForm.new(session.fetch('form', {}))
  end

  def post
    form_params = params.fetch(
      'security_form',
      {}
    ).permit(
      :security_requested_alert_priority_level,
      :security_critical_resources_description,
      :security_does_account_hold_pii,
      :security_does_account_hold_pci_data
    ).to_h
    @form = SecurityForm.new(form_params)
    return render :security if @form.invalid?

    session['form'] = session.fetch('form', {}).merge form_params

    redirect_to administrators_path
  end
end
