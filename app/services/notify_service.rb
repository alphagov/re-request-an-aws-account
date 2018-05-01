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
      email_address: 'richard.towers@digital.cabinet-office.gov.uk',
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

  def new_user_email_support(email, requester_email, pull_request_url)
    unless @notify_api_key
      Rails.logger.warn 'Warning: no NOTIFY_API_KEY set. Skipping emails.'
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.send_email(
      email_address: 'richard.towers@digital.cabinet-office.gov.uk',
      template_id: '3aa6c219-a978-46a4-880f-68f908fb502c',
      personalisation: {
        email: email,
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
        email: email,
        pull_request_url: pull_request_url
      }
    )
  end
end