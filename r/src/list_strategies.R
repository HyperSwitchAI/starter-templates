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

    # List the strategies
    response <- request(glue("{BASE_URL}/admin/strategies/list")) %>%
      req_headers(
        "Content-Type" = "application/json",
        "Authorization" = glue("Bearer {token}")
      ) %>%
      req_method("GET") %>%
      req_perform()

    # Parse response
    result <- fromJSON(resp_body_string(response))
    
    # Replace NA with empty string for cleaner output
    result$strategies$endpoint[is.na(result$strategies$endpoint)] <- ""
    
    cat("\n\033[32m✅ Strategies listed successfully\033[0m\n\n")
    
    # Print strategies in a more readable format
    strategies <- result$strategies
    cat("Strategies:\n")
    for (i in 1:nrow(strategies)) {
      cat("\n", i, ".", 
          "\n   Code:", strategies$code[i],
          "\n   Type:", strategies$type[i],
          "\n   Endpoint:", strategies$endpoint[i], "\n")
    }

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