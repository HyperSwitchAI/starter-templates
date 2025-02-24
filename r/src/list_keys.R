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

    # List the keys
    response <- request(glue("{BASE_URL}/admin/keys/list")) %>%
      req_headers(
        "Content-Type" = "application/json",
        "Authorization" = glue("Bearer {token}")
      ) %>%
      req_method("GET") %>%
      req_perform()

    # Parse response
    result <- fromJSON(resp_body_string(response))
    
    cat("\n\033[32m✅ Keys listed successfully\033[0m\n\n")
    
    # Print keys in a more readable format
    keys <- result$keys
    cat("Keys:\n")
    for (i in 1:nrow(keys)) {
      cat("\n", i, ".", 
          "\n   Key ID:", keys$keyId[i],
          "\n   Provider:", keys$provider[i], "\n")
    }

    cat("\nNote: Neither the API key values nor the encryption fragments are included in the response.\n")

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