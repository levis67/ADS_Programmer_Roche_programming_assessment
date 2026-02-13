# Question 3: TLG - Adverse Events Reporting
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
library(gtsummary)
library(pharmaverseadam)
library(gt)

base::sink(here::here("output", "question_3_1_log.txt"), split = TRUE)
base::cat("Script started at:", base::Sys.time(), "\n\n")

# 2. Read raw datasets

adae <- admiral::convert_blanks_to_na(pharmaverseadam::adae) %>% 
  dplyr::filter(TRTEMFL == "Y")

adsl <- admiral::convert_blanks_to_na(pharmaverseadam::adsl)

# 3. Create the summary

ae_summary_table <- adae %>% 
  gtsummary::tbl_hierarchical(
    variables = c(AESOC, AETERM),
    by = TRT01A,
    id = USUBJID,
    denominator = adsl,
    overall_row = TRUE,
    label = "..ard_hierarchical_overall.." ~ "Treatment Emergent AEs"
  ) %>% 
  gtsummary::add_overall(last = TRUE, col_label = "**Total Population**  \nN = {N}") %>% 
  gtsummary::sort_hierarchical() %>% 
  as_gt()

gt::gtsave(ae_summary_table, here("output", "ae_summary_table.html"))

# 4. Closing log file

base::cat("\nScript finished successfully at:", base::Sys.time(), "\n")
base::sink()
