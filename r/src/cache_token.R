library(httr2)
library(jsonlite)
library(dotenv)
library(glue)

# Load environment variables
load_dot_env()

TOKEN_CACHE_FILE <- ".token-cache.json"
BASE_URL <- "https://api.hyperswitchai.com"

get_token <- function() {
  # Check for cached token
  if (file.exists(TOKEN_CACHE_FILE)) {
    cache <- fromJSON(TOKEN_CACHE_FILE)
    # Check if token is still valid (with 5 minute buffer)
    if (cache$expires_at > as.numeric(Sys.time()) + 300) {
      return(cache$token)
    }
  }

  # Get new token
  response <- request(glue("{BASE_URL}/auth")) %>%
    req_headers("Content-Type" = "application/json") %>%
    req_body_json(list(
      username = Sys.getenv("USERNAME"),
      password = Sys.getenv("PASSWORD")
    )) %>%
    req_perform()

  if (resp_status(response) != 200) {
    stop("Authentication failed")
  }

  result <- resp_body_json(response)
  token <- result$token

  # Cache token with 1 hour expiry
  cache <- list(
    token = token,
    expires_at = as.numeric(Sys.time()) + 3600
  )
  write(toJSON(cache), TOKEN_CACHE_FILE)

  return(token)
}

# Execute if run directly
if (sys.nframe() == 0) {
  tryCatch({
    token <- get_token()
    cat("\n✅ Token cached successfully\n")
  }, error = function(e) {
    cat("\n❌ Error:", e$message, "\n")
  })
} 