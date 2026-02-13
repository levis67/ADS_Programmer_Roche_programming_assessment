# Question 1: SDTM DS Domain Creation using {sdtm.oak}
# Author: Boudart Alexandre
# Date: 12.02.2026

# 1. Load packages used and log file creation

library(sdtm.oak)
library(dplyr)
library(admiral)
library(pharmaverseraw)
library(pharmaversesdtm)
library(here)

base::sink(here::here("output", "question_1_log.txt"), split = TRUE)
base::cat("Script started at:", base::Sys.time(), "\n\n")

# 2. Read raw datasets

ds_raw_init <- pharmaverseraw::ds_raw
dm <- admiral::convert_blanks_to_na(pharmaversesdtm::dm)

# 3. Create id vars in the raw dataset

ds_raw <- ds_raw_init %>%
  admiral::convert_blanks_to_na() %>% 
  sdtm.oak::generate_oak_id_vars(
    pat_var = "PATNUM", 
    raw_src = "ds_raw"
    )

# 4. Read study controlled terminology

study_ct <- utils::read.csv(here::here("input", "sdtm_ct.csv"), stringsAsFactors = FALSE) %>%
  admiral::convert_blanks_to_na()

# CREATING THE DS DOMAIN:

# 5. Map topic variable (DSTERM & DSDECOD)

# Checking the value of DSDECOD and DSTERM to see if
# there corresponding terms in study_ct
ds_raw$IT.DSDECOD %>% base::unique()
ds_raw$IT.DSTERM %>% base::unique()

# See the value of OTHERSP to unsure the conditional adding will work
ds_raw$OTHERSP %>% base::unique()

ds_topic <-
  # If OTHERSP is Null, IT.DSDECOD is mapped in DSDECOD using C66727
  # study controlled terminology terms. 
  sdtm.oak::assign_ct(
    raw_dat = sdtm.oak::condition_add(ds_raw, is.na(OTHERSP)),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    ct_spec = study_ct,
    ct_clst = "C66727",
    id_vars = sdtm.oak::oak_id_vars()
  ) %>% 
  # If OTHERSP is not Null, OTHERSP is mapped in DSDECOD
  sdtm.oak::assign_no_ct(
    raw_dat = sdtm.oak::condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSDECOD",
    id_vars = sdtm.oak::oak_id_vars()
  ) %>% 
  # If OTHERSP is Null, IT.DSTERM is mapped in DSTERM
  sdtm.oak::assign_no_ct(
    raw_dat = sdtm.oak::condition_add(ds_raw, is.na(OTHERSP)),
    raw_var = "IT.DSTERM",
    tgt_var = "DSTERM",
    id_vars = sdtm.oak::oak_id_vars()
  ) %>% 
  # If OTHERSP is not Null, OTHERSP is mapped in DSTERM
  sdtm.oak::assign_no_ct(
    raw_dat = sdtm.oak::condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSTERM",
    id_vars = sdtm.oak::oak_id_vars()
  )

# Displaying of this message after running the above code, 
# while, after checking, the terms are properly mapped in ds:
# ℹ These terms could not be mapped per the controlled terminology: 
# "Randomized", "Completed", "Study Terminated by Sponsor", 
# "Screen Failure", and "Lost to Follow-Up".

# Check if DSDECOD and DSTERM are mapped well
ds_topic %>% dplyr::filter(is.na(DSDECOD))
ds_raw %>% dplyr::filter(is.na(IT.DSDECOD))
ds_topic %>% dplyr::filter(is.na(DSTERM))
ds_raw %>% dplyr::filter(is.na(IT.DSTERM))

# 6. Map the rest of the variables and Create SDTM derived variable

# See the value of each column of interest
ds_raw$IT.DSSTDAT %>% base::unique() # No unknown month/day/year or missing date
ds_raw$DSDTCOL %>% base::unique() # No unknown month/day/year or missing date
ds_raw$DSTMCOL %>% base::unique() # na times

ds <- ds_topic %>% 
  # If IT.DSDECOD == Randomized, DSCAT = PROTOCOL MILESTONE
  # else DSCAT = DISPOSITION EVENT
  # And if OTHERSP is not Null, DSCAT = OTHER EVENT
  sdtm.oak::hardcode_no_ct(
    raw_dat = sdtm.oak::condition_add(ds_raw, IT.DSDECOD == "Randomized"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "PROTOCOL MILESTONE",
    id_vars = sdtm.oak::oak_id_vars()
  ) %>% 
  sdtm.oak::hardcode_no_ct(
    raw_dat = sdtm.oak::condition_add(ds_raw, IT.DSDECOD != "Randomized"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "DISPOSITION EVENT",
    id_vars = sdtm.oak::oak_id_vars()
  ) %>% 
  sdtm.oak::hardcode_no_ct(
    raw_dat = sdtm.oak::condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSCAT",
    tgt_val = "OTHER EVENT",
    id_vars = sdtm.oak::oak_id_vars()
  ) %>% 
  
  # IT.DSSTDAT is mapped in DSSTDTC converted in ISO8601 format
  sdtm.oak::assign_datetime(
    raw_dat = ds_raw,
    raw_var = "IT.DSSTDAT",
    tgt_var = "DSSTDTC",
    raw_fmt = c("m-d-y")
  ) %>% 
  # DSDTCOL and DSTMCOL are mapped in DSDTC converted in ISO8601 format
  sdtm.oak::assign_datetime(
    raw_dat = ds_raw,
    raw_var = c("DSDTCOL", "DSTMCOL"),
    tgt_var = "DSDTC",
    raw_fmt = c("m-d-y", "H:M")
  ) %>% 
  # Map VISIT from INSTANCE using assign_ct
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISIT",
    ct_spec = study_ct,
    ct_clst = "VISIT",
    id_vars = oak_id_vars()
  ) %>% 
  # Map VISITNUM from INSTANCE using assign_ct
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISITNUM",
    ct_spec = study_ct,
    ct_clst = "VISITNUM",
    id_vars = oak_id_vars()
  ) %>% 
  dplyr::mutate(
    STUDYID = ds_raw$STUDY,
    DOMAIN = "DS",
    USUBJID = paste0(STUDYID, "-", ds_raw$PATNUM)
    ) %>% 
  sdtm.oak::derive_seq(
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
  dplyr::select(
    STUDYID, DOMAIN, USUBJID, DSSEQ, DSTERM, DSDECOD, DSCAT, VISITNUM, VISIT, 
    DSDTC, DSSTDTC, DSSTDY
    )

# Check if DSCAT is mapped well according to rules
ds %>% dplyr::filter(DSCAT == "PROTOCOL MILESTONE")
ds_raw %>% dplyr::filter(IT.DSDECOD == "Randomized")
ds %>% dplyr::filter(DSCAT == "DISPOSITION EVENT")
ds_raw %>% dplyr::filter(IT.DSDECOD != "Randomized")

utils::write.csv(ds, file = here::here("output", "ds_sdtm_dataset.csv"))

# 6. Closing log file

base::cat("\nScript finished successfully at:", base::Sys.time(), "\n")
base::sink()
