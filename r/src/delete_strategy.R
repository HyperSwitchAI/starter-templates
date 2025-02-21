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

    # Delete the strategy
    response <- request(glue("{BASE_URL}/admin/strategies/delete-strategy")) %>%
      req_headers(
        "Content-Type" = "application/json",
        "Authorization" = glue("Bearer {token}")
      ) %>%
      req_body_json(list(
        code = "claude-proxy-1"
      )) %>%
      req_perform()

    # Handle response
    response_text <- resp_body_string(response)
    response_status <- resp_status(response)

    if (response_status != 200) {
      if (response_status == 404) {
        cat("\n\033[33m⚠️  Strategy not found - it may have already been deleted\033[0m\n")
        return()
      }
      
      cat(glue("\n\033[31mServer response: {response_status} {response_text}\033[0m\n"))
      stop(glue("Failed to delete strategy: HTTP {response_status} {http_status(response_status)$reason}"))
    }

    cat("\n\033[32m✅ Strategy deleted successfully\033[0m\n")

  }, error = function(e) {
    cat("\nError:", e$message, "\n")
    if (!is.null(e$body)) {
      cat("Response body:", e$body, "\n")
    }
  })
}

# Execute if run directly
if (sys.nframe() == 0) {
  main()
} 