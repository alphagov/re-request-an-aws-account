Rails.application.config.middleware.use OmniAuth::Builder do
  google_client_id = ENV['GOOGLE_CLIENT_ID']
  google_client_secret = ENV['GOOGLE_CLIENT_SECRET']

  if google_client_id && google_client_secret
    provider :google_oauth2,
             google_client_id,
             google_client_secret,
             hd: 'digital.cabinet-office.gov.uk',
             prompt: :consent
  end
end