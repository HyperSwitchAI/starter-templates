library(httr2)
library(jsonlite)
library(dotenv)
library(glue)

# Load environment variables
load_dot_env()

BASE_URL <- "https://api.hyperswitchai.com"

# Source the cache_token.R file to get access to its functions
source("src/cache_token.R")

main <- function() {
  tryCatch({
    # Get cached token using the imported function
    token <- get_token()

    # Add a new strategy
    response <- request(glue("{BASE_URL}/admin/strategies/add-strategy")) %>%
      req_headers(
        "Content-Type" = "application/json",
        "Authorization" = glue("Bearer {token}")
      ) %>%
      req_body_json(list(
        code = "claude-proxy-1",
        type = "proxy",
        model = "claude-3-5-sonnet-20240620",
        keyId = "claude-key-1",
        provider = "anthropic"
      )) %>%
      req_perform()

    # Handle response
    if (resp_status(response) != 200) {
      response_text <- resp_body_text(response)
      
      # Print full response details for debugging
      cat("\nStatus Code:", resp_status(response), "\n")
      cat("Response Headers:\n")
      print(resp_headers(response))
      cat("\nResponse Body:\n")
      cat(response_text, "\n")
      
      if (resp_status(response) == 409) {
        # Try to parse JSON error response
        tryCatch({
          error_json <- fromJSON(response_text)
          if (!is.null(error_json$error) && error_json$error$code == "duplicate_strategy_code") {
            cat("\n\033[33m⚠️  Strategy already exists with this code\033[0m\n")
            return()
          }
          # Print the parsed error JSON for more detail
          cat("\nParsed Error JSON:\n")
          print(error_json)
        }, error = function(e) {
          cat("\nCould not parse response as JSON:", e$message, "\n")
        })
      }
      
      cat("\n\033[31mServer response:", resp_status(response), response_text, "\033[0m\n")
      stop(glue("Failed to add strategy: {resp_status(response)}"))
    }

    cat("\n\033[32m✅ Strategy added successfully\033[0m\n")

  }, error = function(e) {
    cat("Error:", e$message, "\n")
  })
}

# Execute if run directly
if (sys.nframe() == 0) {
  main()
}