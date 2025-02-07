module JsonHelper
  def json_response
    JSON.parse(response.body)
  end

  def json_response_symbolized
    JSON.parse(response.body, symbolize_names: true)
  end
end