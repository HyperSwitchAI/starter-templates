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

    # Add a new API key
    response = conn.post('/admin/keys/add-key') do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{token}"
      req.body = {
        keyId: 'claude-key-1',
        encryptionFragment: 'OpenThePodBayDoorsHAL-2001',
        provider: 'anthropic',
        apiKey: 'sk-ant-api03-LhOEBAVFlPnTIy8e80m9lNkJpKBSV3v7xSwXkpX4f02lICRAAAAAAAAAAAAAAA'
      }
    end

    # Handle response
    unless response.success?
      if response.status == 409
        error = response.body  # Body is already parsed as JSON
        if error.dig('error', 'code') == 'duplicate_key_id'
          puts "\n\e[33m⚠️  Key already exists with this ID\e[0m"
          return
        end
      end
      
      puts "\n\e[31mServer response: #{response.status} #{response.body}\e[0m"
      raise "Failed to add key: #{response.reason_phrase}"
    end

    puts "\n\e[32m✅ Key added successfully\e[0m"

  rescue => e
    puts "Error: #{e.message}"
  end
end

# Run if this file is executed directly
main if __FILE__ == $PROGRAM_NAME 