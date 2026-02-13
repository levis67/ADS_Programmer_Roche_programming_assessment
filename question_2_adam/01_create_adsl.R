# Question 2: ADaM ADSL Dataset Creation
# Author: Boudart Alexandre
# Date: 13.02.2026

# 1. Load packages used and log file creation

library(metacore)
library(metatools)
library(pharmaversesdtm)
library(admiral)
library(xportr)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(here)

base::sink(here::here("output", "question_2_log.txt"), split = TRUE)
base::cat("Script started at:", base::Sys.time(), "\n\n")

# 2. Read raw datasets

dm <- admiral::convert_blanks_to_na(pharmaversesdtm::dm)
vs <- admiral::convert_blanks_to_na(pharmaversesdtm::vs)
ex <- admiral::convert_blanks_to_na(pharmaversesdtm::ex)
ds <- admiral::convert_blanks_to_na(pharmaversesdtm::ds)
ae <- admiral::convert_blanks_to_na(pharmaversesdtm::ae)
suppdm <- admiral::convert_blanks_to_na(pharmaversesdtm::suppdm)

# 3. 

# 6. Closing log file

base::cat("\nScript finished successfully at:", base::Sys.time(), "\n")
base::sink()
