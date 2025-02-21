library(httr2)
library(jsonlite)
library(dotenv)
library(glue)

# Load environment variables
load_dot_env()

BASE_URL <- "https://api.hyperswitchai.com"

main <- function() {
  tryCatch({
    # Check for required environment variables
    if (Sys.getenv("USERNAME") == "" || Sys.getenv("PASSWORD") == "") {
      stop("USERNAME and PASSWORD must be set in a .env file in the r directory. You can rename .env.sample to .env and fill in your own email and password.")
    }

    # Get token
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
    
    # Print success message with green color and token only once
    cat("\n\033[32m✅ Token successfully retrieved\033[0m\n")
    cat("\nToken:", result$token, "\n")  # Print token only once

  }, error = function(e) {
    cat("Error:", e$message, "\n")
  })
}

# Execute if run directly
if (sys.nframe() == 0) {
  main()
} 