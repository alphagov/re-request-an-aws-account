class CheckYourAnswersController < ApplicationController
  def check_your_answers
    @answers = session.fetch('form', {}).with_indifferent_access
    @form = AccountDetailsForm.new(session.fetch('form', {}))
  end

  def post
    @form = AccountDetailsForm.new(session.fetch('form', {}))
    @answers = session.fetch('form', {}).with_indifferent_access

    all_params = session['form']

    account_name = all_params['account_name']
    account_description = all_params['account_description']
    programme_or_other = all_params['programme_or_other']
    admin_users = all_params['admin_users']
    email = session['email']

    begin
      tags = {
        'description' => account_description,
        'programme' => programme_or_other,

        'team-name' => all_params['team_name'],
        'team-email-address' => all_params['team_email_address'],
        'team-lead-name' => all_params['team_lead_name'],
        'team-lead-phone-number' => all_params['team_lead_phone_number'],
        'team-lead-role' => all_params['team_lead_role'],

        'service-name' => all_params['service_name'],
        'service-is-out-of-hours-support-provided' => all_params['service_is_out_of_hours_support_provided'],

        'security-requested-alert-priority-level' => all_params['security_requested_alert_priority_level'],
        'security-critical-resources-description' => all_params['security_critical_resources_description'],
        'security-does-account-hold-pii' => all_params['security_does_account_hold_personally_identifiable_information'],
        'security-does-account-hold-pci-data' => all_params['security_does_account_hold_pci_data']
      }

      if all_params['service_is_out_of_hours_support_provided'] == 'true'
        tags.merge!(
          {
            'out-of-hours-support-contact-name' => all_params['out_of_hours_support_contact_name'],
            'out-of-hours-support-phone-number' => all_params['out_of_hours_support_phone_number'],
            'out-of-hours-support-pagerduty-link' => all_params['out_of_hours_support_pagerduty_link'],
            'out-of-hours-support-email-address' => all_params['out_of_hours_support_email_address']
          }
        )
      end

      tags.compact!

      pull_request_url = GithubService.new.create_new_account_pull_request(
        account_name,
        account_description,
        programme_or_other,
        email,
        admin_users,
        tags
      )

      session['pull_request_url'] = pull_request_url

      notify_service = NotifyService.new
      notify_service.new_account_email_support(
        account_name: account_name,
        account_description: account_description,
        programme: programme_or_other,
        email: email,
        pull_request_url: pull_request_url,
        admin_users: admin_users
      )
      notify_service.new_account_email_user email, account_name, pull_request_url

      redirect_to confirmation_account_path
    rescue Errors::AccountAlreadyExistsError => e
      @form.errors.add 'account_name', "account #{e.message} already exists"
      Errors::log_error 'Account already existed', e
      return render :check_your_answers
    rescue StandardError => e
      @form.errors.add 'commit', 'unknown error when opening pull request or sending email'
      Errors::log_error 'Failed to raise account creation PR or send email', e
      return render :check_your_answers
    end
  end
end
