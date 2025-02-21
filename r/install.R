# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Install required packages if not already installed
required_packages <- c(
  "httr2",      # Modern HTTP client
  "jsonlite",   # JSON handling
  "dotenv",     # Environment variable management
  "glue"        # String interpolation
)

for (package in required_packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
} 