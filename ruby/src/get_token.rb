require 'dotenv'
require 'faraday'
require 'json'

# Load environment variables from .env file
Dotenv.load

BASE_URL = 'https://api.hyperswitchai.com'

def main
  # Check for required environment variables
  unless ENV['USERNAME'] && ENV['PASSWORD']
    raise 'USERNAME and PASSWORD must be set in a .env file in the ruby directory. You can rename .env.sample to .env and fill in your own email and password.'
  end

  # Create HTTP client
  conn = Faraday.new(url: BASE_URL) do |f|
    f.request :json # Encode request bodies as JSON
    f.response :json # Decode response bodies as JSON
  end

  begin
    # Make authentication request
    response = conn.post('/auth') do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        username: ENV['USERNAME'],
        password: ENV['PASSWORD']
      }
    end

    # Check response status
    unless response.success?
      raise 'Authentication failed'
    end

    # Extract token from response
    token = response.body['token']

    puts "\n\e[32m✅ Token successfully retrieved\e[0m"
    puts "Token: #{token}"

  rescue => e
    puts "Error: #{e.message}"
  end
end

# Run if this file is executed directly
main if __FILE__ == $PROGRAM_NAME 