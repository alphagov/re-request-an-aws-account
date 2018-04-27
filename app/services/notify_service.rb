require 'notifications/client'

class NotifyService
  def self.new_account_email_support(personalisation)
    client = Notifications::Client.new(ENV.fetch 'NOTIFY_API_KEY')
    client.send_email(
      email_address: 'richard.towers@digital.cabinet-office.gov.uk',
      template_id: '95358639-a3d0-4f27-baf9-50bf530891a8',
      personalisation: personalisation
    )
  end

  def self.new_account_email_user(email, account_name, card_id)
    client = Notifications::Client.new(ENV.fetch 'NOTIFY_API_KEY')
    client.send_email(
      email_address: email,
      template_id: '4db8b8a6-1486-44e3-9bf4-572d64be7881',
      personalisation: {
        account_name: account_name,
        card_id: card_id
      }
    )
  end
end