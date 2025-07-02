Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           Rails.application.credentials.google[:client_id],
           Rails.application.credentials.google[:client_secret],
           {
             scope: 'email,profile',
             prompt: 'select_account',
             image_aspect_ratio: 'square',
             image_size: 50
           }
end

OmniAuth.config.allowed_request_methods = [:post, :get]