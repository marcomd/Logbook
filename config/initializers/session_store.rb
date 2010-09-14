# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Logbook_session',
  :secret      => 'ced8fd6d2e04c63cc08d4f6f0907f135c7a87c80b8489a0f939288eb477a1b8c63eff94b47d4e3af927ba8e8ec3a479134fb66b6d25e607c86fcf2934ca30e9d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
