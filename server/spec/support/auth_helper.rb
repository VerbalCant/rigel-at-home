module AuthHelper
  def auth_headers(agent)
    token = JsonWebToken.encode(agent_id: agent.id)
    { 'Authorization' => "Bearer #{token}" }
  end

  def json_headers
    { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  def authenticated_headers(agent)
    json_headers.merge(auth_headers(agent))
  end
end