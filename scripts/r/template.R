#============================================================================
# Template for 20295 Microeconometrics Problem Sets (R version)
# Group number: [INSERT GROUP NUMBER]
# Group composition: [INSERT NAMES]
#============================================================================

#=============================================================================
#                                 Setup
#=============================================================================

# Clear workspace
rm(list = ls())

# Set reproducibility
set.seed(123456)

# Load required libraries
required_packages <- c("data.table", "dplyr", "ggplot2", "stargazer", "haven")

# Install packages if needed
install_if_missing <- function(packages) {
    new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
    if(length(new_packages)) {
        install.packages(new_packages)
        cat("Installed packages:", paste(new_packages, collapse = ", "), "\n")
    }
}

# Uncomment to install missing packages
# install_if_missing(required_packages)

# Load libraries
invisible(lapply(required_packages, library, character.only = TRUE))

#=============================================================================
#                              Path Setup
#=============================================================================

# Find project root (looks for README.md with "20295")
find_project_root <- function() {
    current_dir <- getwd()
    max_levels <- 5
    level <- 0
    
    while (level <= max_levels) {
        if (file.exists("README.md")) {
            readme_content <- readLines("README.md", n = 1, warn = FALSE)
            if (length(readme_content) > 0 && grepl("20295", readme_content[1])) {
                return(getwd())
            }
        }
        
        if (level < max_levels) {
            setwd("..")
            level <- level + 1
        } else {
            setwd(current_dir)
            return(getwd())
        }
    }
}

# Initialize paths
project_root <- find_project_root()
ps_number <- X  # Replace X with actual problem set number

# Set up paths
data_dir <- file.path(project_root, "data")
ps_data <- file.path(project_root, paste0("ps", ps_number), paste0("ps", ps_number, "_data"))
ps_output <- file.path(project_root, paste0("ps", ps_number), paste0("ps", ps_number, "_output"))
outputs_dir <- file.path(project_root, "outputs")

# Create output directory if it doesn't exist
if (!dir.exists(ps_output)) {
    dir.create(ps_output, recursive = TRUE)
}

cat("Project root:", project_root, "\n")
cat("PS data directory:", ps_data, "\n")
cat("PS output directory:", ps_output, "\n")

#=============================================================================
#                                Questions
#=============================================================================

# Question 1
# [Insert question text as comment]

# Load data
data <- read_dta(file.path(ps_data, "datafile.dta"))

# Your analysis code here
model1 <- lm(y ~ x, data = data)

# Save results
stargazer(model1, 
          out = file.path(ps_output, "table_q1.tex"),
          title = "Question 1 Results",
          type = "latex")

# Question 2
# [Insert question text as comment]

# Your analysis code here

# Save plot
ggsave(filename = file.path(ps_output, "plot_q2.pdf"), 
       width = 8, height = 6)

cat("Analysis completed. Results saved to:", ps_output, "\n")