# frozen_string_literal: true

# Devise settings. Only the options this app relies on are listed; everything else uses
# Devise's defaults. The full list is in the devise gem's install template.
Devise.setup do |config|
  # Sender shown on password reset emails
  config.mailer_sender = "myBooks <no-reply@mybooks.example>"

  require "devise/orm/active_record"

  # Log in with email. Emails are stripped and compared case-insensitively.
  config.authentication_keys    = [ :email ]
  config.case_insensitive_keys  = [ :email ]
  config.strip_whitespace_keys  = [ :email ]

  config.skip_session_storage = [ :http_auth ]

  # bcrypt cost. Kept low in tests so the suite stays fast.
  config.stretches = Rails.env.test? ? 1 : 12

  # Changing the email or password sends a notice to the old address
  config.send_email_changed_notification = true

  # Changing the email takes effect immediately (no :confirmable module)
  config.reconfirmable = false

  config.expire_all_remember_me_on_sign_out = true

  config.password_length = 8..128
  config.email_regexp    = /\A[^@\s]+@[^@\s]+\z/

  # Logging out is a DELETE request (button_to in the header)
  config.sign_out_via = :delete

  # Hotwire/Turbo: failed form submissions must answer 422 and redirects 303,
  # otherwise Turbo won't render the error or follow the redirect.
  config.navigational_formats = [ "*/*", :html, :turbo_stream ]
  config.responder.error_status    = :unprocessable_content
  config.responder.redirect_status = :see_other
end
