require 'omniauth'

OmniAuth.config.logger = Rails.logger

# Configure OmniAuth to handle session requirements
OmniAuth.config.request_validation_phase = lambda { |env|
  # Skip session validation for non-auth API routes
  return if env['PATH_INFO'] =~ %r{^/api/(?!auth/)}
  
  # Validate session for auth routes
  if env['rack.session'].nil?
    Rails.logger.error("ALAINA: No session found for OAuth route: #{env['PATH_INFO']}")
    raise OmniAuth::NoSessionError, "Session not found for OAuth authentication"
  end
}

# Allow test mode in development
if Rails.env.development?
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
    provider: 'developer',
    uid: '123545',
    info: {
      name: 'Test User',
      email: 'test@example.com'
    }
  })
end 