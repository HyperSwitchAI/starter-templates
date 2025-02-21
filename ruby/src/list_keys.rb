require 'dotenv'
require 'faraday'
require 'json'

# Load environment variables from .env file
Dotenv.load

BASE_URL = 'https://api.hyperswitchai.com'

# Source the cache_token.rb file to get access to its functions
require_relative 'cache_token'

def main
  begin
    # Get cached token using the imported function
    token = get_token

    # Create HTTP client
    conn = Faraday.new(url: BASE_URL) do |f|
      f.request :json
      f.response :json
    end

    # List all API keys
    response = conn.get('/admin/keys/list') do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{token}"
    end

    # Handle response
    unless response.success?
      puts "\n\e[31mServer response: #{response.status} #{response.body}\e[0m"
      raise "Failed to list keys: #{response.reason_phrase}"
    end

    puts "\n\e[32m✅ Keys listed successfully\e[0m"
    puts JSON.pretty_generate(response.body)
    puts "\nNote that neither the API key values nor the encryption fragments are included in the response."

  rescue => e
    puts "Error: #{e.message}"
  end
end

# Run if this file is executed directly
main if __FILE__ == $PROGRAM_NAME 