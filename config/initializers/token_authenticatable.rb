Devise::TokenAuthenticatable.setup do |config|
  # enables the expiration of a token after a specified amount of time,
  # defaults to nil
  config.token_expires_in = 1.day
end