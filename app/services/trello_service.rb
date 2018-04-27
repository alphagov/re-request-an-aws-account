require 'trello'

Trello.configure do |config|
  config.developer_public_key = ENV.fetch 'TRELLO_DEVELOPER_PUBLIC_KEY'
  config.member_token = ENV.fetch 'TRELLO_MEMBER_TOKEN'
end

class TrelloService
  def self.create_new_aws_account_card(email, account_name, programme, pull_request_url)
    card = Trello::Card.create(
      list_id: '5ade08f50b5895b033065f71',
      name: "#{account_name} (#{programme})",
      desc: "New AWS account requested by #{email}\n\nA pull request has been generated for you: #{pull_request_url}"
    )
    card.short_url
  end

  def create_new_user_card()
    # Other board list_id: 5ae31f8d9d85f8857b86b5c2

  end
end