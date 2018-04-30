require 'trello'

trello_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
trello_member_token = ENV['TRELLO_MEMBER_TOKEN']
trello_is_configured = trello_public_key && trello_member_token

if trello_is_configured
  Trello.configure do |config|
    config.developer_public_key = trello_public_key
    config.member_token = trello_member_token
  end
end

class TrelloService
  def self.create_new_aws_account_card(email, account_name, programme, pull_request_url)
    unless Trello.configuration.member_token
      Rails.logger.warn 'Warning: no TRELLO_MEMBER_TOKEN set. Skipping trello.'
      return nil
    end

    card = Trello::Card.create(
      list_id: '5ade08f50b5895b033065f71',
      name: "#{account_name} (#{programme})",
      desc: "New AWS account requested by #{email}\n\nA pull request has been generated for you: #{pull_request_url}"
    )
    card.short_url
  end

  def self.create_new_user_card(email, requested_by_email, pull_request_url)
    unless Trello.configuration.member_token
      Rails.logger.warn 'Warning: no TRELLO_MEMBER_TOKEN set. Skipping trello.'
      return nil
    end

    card = Trello::Card.create(
      list_id: '5ae31f8d9d85f8857b86b5c2',
      name: "New user: #{email}",
      desc: "Requested by #{requested_by_email}\nA pull request has been generated for you: #{pull_request_url}"
    )
    card.short_url
  end
end