require 'notifications/client'

class NotifyService
  def initialize
    @notify_api_key = ENV['NOTIFY_API_KEY']
  end

  def new_account_email_support(personalisation)
    unless @notify_api_key
      Rails.logger.warn 'Warning: no NOTIFY_API_KEY set. Skipping emails.'
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.send_email(
      email_address: 'gds-aws-account-management@digital.cabinet-office.gov.uk',
      template_id: '95358639-a3d0-4f27-baf9-50bf530891a8',
      personalisation: personalisation
    )
  end

  def new_account_email_user(email, account_name, pull_request_url)
    unless @notify_api_key
      Rails.logger.warn 'Warning: no NOTIFY_API_KEY set. Skipping emails.'
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.send_email(
      email_address: email,
      template_id: '4db8b8a6-1486-44e3-9bf4-572d64be7881',
      personalisation: {
        account_name: account_name,
        pull_request_url: pull_request_url
      }
    )
  end

  def new_user_email_support(email_list, requester_email, pull_request_url)
    unless @notify_api_key
      Rails.logger.warn 'Warning: no NOTIFY_API_KEY set. Skipping emails.'
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.send_email(
      email_address: 'gds-aws-account-management@digital.cabinet-office.gov.uk',
      template_id: '3aa6c219-a978-46a4-880f-68f908fb502c',
      personalisation: {
        subject_slug: email_list.split('@').first + (email_list.split('@').size > 2 ? ' and friends' : ''),
        email_list: email_list,
        requester_email: requester_email,
        pull_request_url: pull_request_url
      }
    )
  end

  def new_user_email_user(email, requester_email, pull_request_url)
    unless @notify_api_key
      Rails.logger.warn 'Warning: no NOTIFY_API_KEY set. Skipping emails.'
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.send_email(
      email_address: requester_email,
      template_id: '6d8fa62d-e3f2-4783-aed7-e1412ed031cc',
      personalisation: {
        email_list: email,
        pull_request_url: pull_request_url
      }
    )
  end

  def remove_user_email_user(email, requester_email, pull_request_url)
    unless @notify_api_key
      Rails.logger.warn 'Warning: no NOTIFY_API_KEY set. Skipping emails.'
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.send_email(
      email_address: requester_email,
      template_id: '9371e0f9-71b9-4757-b861-92c220cd5fac',
      personalisation: {
        email_list: email,
        pull_request_url: pull_request_url
      }
    )
  end

  def remove_user_email_support(email_list, requester_email, pull_request_url)
    unless @notify_api_key
      Rails.logger.warn 'Warning: no NOTIFY_API_KEY set. Skipping emails.'
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.send_email(
      email_address: 'gds-aws-account-management@digital.cabinet-office.gov.uk',
      template_id: 'cccf0946-f065-4687-bad8-a1a5af865462',
      personalisation: {
        subject_slug: email_list.split('@').first + (email_list.split('@').size > 2 ? ' and friends' : ''),
        email_list: email_list,
        requester_email: requester_email,
        pull_request_url: pull_request_url
      }
    )
  end

  def reset_password_email_user(requester_name, requester_email, pull_request_url)
    unless @notify_api_key
      Rails.logger.warn 'Warning: no NOTIFY_API_KEY set. Skipping emails.'
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.send_email(
      email_address: requester_email,
      template_id: 'afff4178-f7bc-4152-9200-d8bf614d7073',
      personalisation: {
        pull_request_url: pull_request_url
      }
    )
  end

  def reset_password_email_support(requester_name, requester_email, pull_request_url)
    unless @notify_api_key
      Rails.logger.warn 'Warning: no NOTIFY_API_KEY set. Skipping emails.'
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.send_email(
      email_address: 'gds-aws-account-management@digital.cabinet-office.gov.uk',
      template_id: 'a4bdbc15-d899-47d9-867e-4e240c1687f9',
      personalisation: {
        requester_name: requester_name,
        requester_email: requester_email,
        pull_request_url: pull_request_url
      }
    )
  end
end
