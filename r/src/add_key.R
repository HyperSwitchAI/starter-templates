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
    token <- get_token()  # Direct call to the function now

    # Add a new API key
    response <- request(glue("{BASE_URL}/admin/keys/add-key")) %>%
      req_headers(
        "Content-Type" = "application/json",
        "Authorization" = glue("Bearer {token}")
      ) %>%
      req_body_json(list(
        keyId = "claude-key-1",
        encryptionFragment = "OpenThePodBayDoorsHAL-2001",
        provider = "anthropic",
        apiKey = "sk-ant-api03-LhOEBAVFlPnTIy8e80m9lNkJpKBSV3v7xSwXkpX4f02lICRAAAAAAAAAAAAAAA"
      )) %>%
      req_perform()

    # Handle response
    if (resp_status(response) != 200) {
      if (resp_status(response) == 409) {
        error_json <- resp_body_json(response)
        if (!is.null(error_json$error) && error_json$error$code == "duplicate_key_id") {
          cat("\n\033[33m⚠️  Key already exists with this ID\033[0m\n")
          return()
        }
      }
      
      error_text <- resp_body_text(response)
      cat("\n\033[31mServer response:", resp_status(response), error_text, "\033[0m\n")
      stop(glue("Failed to add key: {resp_status(response)}"))
    }

    cat("\n\033[32m✅ Key added successfully\033[0m\n")

  }, error = function(e) {
    cat("Error:", e$message, "\n")
  })
}

# Execute if run directly
if (sys.nframe() == 0) {
  main()
} 