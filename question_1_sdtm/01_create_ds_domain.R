# QUESTION 1: SDTM DS DOMAIN CREATION USING {sdtm.oak}
# Author: Boudart Alexandre
# Date: 11.02.2026

# 1. LOAD REQUIRED LIBRARIES

library(sdtm.oak)
library(dplyr)
library(admiral)
library(pharmaverseraw)
library(lubridate)
library(here)

# 2. LOAD RAW DATA

# Load the raw disposition data
# This data set contains information about patient disposition events
# (completion, withdrawal, adverse events, etc.)
ds_raw <- pharmaverseraw::ds_raw

# Display structure to understand the data
str(ds_raw)

# Preview first few records
head(ds_raw)

# Check unique values in key columns
unique(ds_raw %>% select(IT.DSDECOD))

# 3. CREATE STUDY CONTROLLED TERMINOLOGY (CT)

# Controlled Terminology (CT) maps raw collected values to standardized CDISC terms
# This ensures consistency across studies and regulatory compliance
# Structure:
# - codelist_code: CDISC codelist identifier (C66727 = Disposition Event Type)
# - term_code: Unique code for each standardized term
# - term_value: Official CDISC standardized term
# - collected_value: Raw value collected in the study (from eCRF)
# - term_preferred_term: Abbreviated/preferred version of the term
# - term_synonyms: Alternative names for the term

study_ct <- read.csv(here("question_1_sdtm", "sdtm_ct.csv")) %>%
  as_tibble()

# Display CT structure
View(study_ct)

# 4. PREPARE RAW DATA FOR TRANSFORMATION

# Start with raw data and prepare it for oak transformations
# Oak works best with data in a specific format
ds_prep <- ds_raw  %>%
  generate_oak_id_vars(pat_var = "PATNUM", raw_src = "ds_raw")

View(ds_prep)

# 5. CREATE TOPIC VARIABLE (DSTERM & DSDECOD)

# Use condition_add() to map raw values to standardized CDISC terms
# This function looks up values in the CT and adds standardized variables

ds_with_dsdecod_and_dsterm <-
  assign_no_ct(
    raw_dat = ds_prep,
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    id_vars = oak_id_vars()
  ) %>% 
  assign_no_ct(
    raw_dat = ds_prep,
    raw_var = "IT.DSTERM",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  )

ds_final <- ds_with_dsdecod_and_dsterm %>%
  assign_ct(
    raw_dat = ds_prep,
    raw_var = "IT.DSTERM",
    tgt_var = "DSTERM",
    ct_spec = study_ct,
    ct_clst = "C66768",
    id_vars = oak_id_vars()
  ) %>%
  assign_datetime(
    raw_dat = ds_prep,
    raw_var = "IT.DSSTDAT",
    tgt_var = "DSSTDTC",
    raw_fmt = c("MM-DD-YYYY")
  ) %>%
  assign_datetime(
    raw_dat = ds_prep,
    raw_var = "DATE_TIME",
    tgt_var = "DSDTC",
    raw_fmt = c("MM-DD-YYYY HH-MM"),
    id_vars = oak_id_vars()
  ) %>%
  dplyr::mutate(
    STUDYID = ds_raw$STUDY,
    DOMAIN = "DS",
    USUBJID = paste0("01-", ds_raw$PATNUM),
    DSDECOD = case_when(is.na(ds_raw$OTHERSP) ~ ds_raw$DSDECOD,
                        .default = ds_raw$OTHERSP),
    DSCAT = case_when(DSDECOD = "Randomized" ~ "PROTOCOL MILESTONE",
                      !is.na(ds_raw$OTHERSP) ~ "OTHER EVENT",
                      .default = "DISPOSITION EVENT"),
    DSTERM = case_when(is.na(ds_raw$OTHERSP) ~ toupper(ds_raw$IT.DSTERM),
                       .default = ds_raw$OTHERSP),
    DATE_TIME = paste(DSDTCOL, DSTMCOL)
  ) %>%
  derive_seq(
    tgt_var = "DSSEQ",
    rec_vars = c("USUBJID", "DSTERM")
  ) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "DSSTDTC",
    refdt = "RFXSTDTC",
    study_day_var = "DSSTDY"
  ) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "DSSTDY",
    refdt = "RFXENDTC",
    study_day_var = "DSSTDY"
  ) %>%
  select(
    STUDYID, DOMAIN, USUBJID, DSSEQ, DSTERM, DSDECOD, DSCAT, VISITNUM, VISIT, DSDTC,
    DSSTDTC, DSSTDY
  )
