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

    # Delete a strategy
    response = conn.post('/admin/strategies/delete-strategy') do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{token}"
      req.body = {
        code: 'claude-proxy-1'
      }
    end

    # Handle response
    unless response.success?
      if response.status == 404
        puts "\n\e[33m⚠️  Strategy not found - it may have already been deleted\e[0m"
        return
      end
      
      puts "\n\e[31mServer response: #{response.status} #{response.body}\e[0m"
      raise "Failed to delete strategy: #{response.reason_phrase}"
    end

    puts "\n\e[32m✅ Strategy deleted successfully\e[0m"

  rescue => e
    puts "Error: #{e.message}"
  end
end

# Run if this file is executed directly
main if __FILE__ == $PROGRAM_NAME 