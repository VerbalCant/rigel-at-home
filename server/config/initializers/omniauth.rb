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

# Configure OmniAuth to allow GET requests in development
if Rails.env.development?
  OmniAuth.config.allowed_request_methods = [:post, :get]
  OmniAuth.config.silence_get_warning = true
end 