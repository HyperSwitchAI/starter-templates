require 'dotenv'
require 'faraday'
require 'json'
require 'fileutils'

# Load environment variables from .env file
Dotenv.load

API_URL = 'https://api.hyperswitchai.com'
TOKEN_CACHE_FILE = '.token-cache.json'

def get_token
  # Check if we have a cached token
  if File.exist?(TOKEN_CACHE_FILE)
    cache = JSON.parse(File.read(TOKEN_CACHE_FILE))
    # Check if token is still valid (with 5 minute buffer)
    if cache['expiresAt'] > (Time.now.to_f * 1000).to_i + 300000
      return cache['token']
    end
  end

  # Create HTTP client
  conn = Faraday.new(url: API_URL) do |f|
    f.request :json
    f.response :json
  end

  # Make authentication request
  response = conn.post('/auth') do |req|
    req.headers['Content-Type'] = 'application/json'
    req.body = {
      username: ENV['USERNAME'],
      password: ENV['PASSWORD']
    }
  end

  unless response.success?
    raise 'Authentication failed'
  end

  token = response.body['token']

  # Cache token with 1 hour expiry
  cache_data = {
    token: token,
    # Convert to milliseconds to match TypeScript version
    expiresAt: (Time.now.to_f * 1000).to_i + 3600000
  }

  # Write cache file with proper permissions
  File.write(TOKEN_CACHE_FILE, JSON.generate(cache_data))
  FileUtils.chmod(0600, TOKEN_CACHE_FILE)

  token
rescue => e
  puts "Auth error: #{e.message}"
  raise e
end

def main
  begin
    token = get_token

    puts "\n\e[32m✅ Token successfully cached in .token-cache.json\e[0m"
    puts "Token: #{token}"
    puts "\e[36mNow the token is cached in .token-cache.json, you can use it in your code and not have to get a new one all the time (until it expires).\e[0m"
    puts "\e[36mIf you run this code again you should see the same token is being used.\e[0m"

  rescue => e
    puts "Error: #{e.message}"
  end
end

# Run if this file is executed directly
main if __FILE__ == $PROGRAM_NAME 