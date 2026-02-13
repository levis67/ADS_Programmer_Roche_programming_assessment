# Question 3: TLG - Adverse Events Reporting
# Author: Boudart Alexandre
# Date: 13.02.2026

# 1. Load packages used and log file creation

library(admiral)
library(dplyr)
library(here)
library(ggplot2)
library(pharmaverseadam)
library(scales)

base::sink(here::here("output", "question_3_2_log.txt"), split = TRUE)
base::cat("Script started at:", base::Sys.time(), "\n\n")

# 2. Read raw datasets

adae <- admiral::convert_blanks_to_na(pharmaverseadam::adae)

# 3. Create Plot 1

# AESEV column contains the Severity/Intensity

# Summarise counts
ae_counts <- adae %>%
  dplyr::filter(!is.na(AESEV), !is.na(TRT01A)) %>%
  dplyr::count(TRT01A, AESEV)

# Optional: Order severity levels if desired
ae_counts <- ae_counts %>%
  dplyr::mutate(AESEV = factor(AESEV,
                               levels = c("MILD", "MODERATE", "SEVERE")))

# Create bar chart (counts)
plot_1 <- ggplot2::ggplot(ae_counts, aes(x = TRT01A, y = n, fill = AESEV)) +
  geom_bar(stat = "identity", position = "stack") +
  ggplot2::labs(
    title = "AE severity distribution by treatment",
    x = "Treatment Arm",
    y = "Count of AEs",
    fill = "Severity/Intensity"
  ) +
  ggplot2::theme_minimal()

ggplot2::ggsave(
  filename = here::here("output", "plot_1.png"),
  plot = plot_1,
  width = 10,
  height = 6,
  dpi = 300
)

# 4. Create Plot 2

# Total number of subjects
N_total <- adae %>%
  dplyr::distinct(USUBJID) %>%
  base::nrow()

# Subject-level AE dataset (one record per subject per AE)
ae_subject <- adae %>%
  dplyr::filter(!is.na(AETERM), !is.na(USUBJID)) %>%
  dplyr::distinct(USUBJID, AETERM)

# Count subjects with each AE
ae_counts <- ae_subject %>%
  dplyr::count(AETERM, name = "n")

# Compute incidence and 95% CI
ae_incidence <- ae_counts %>%
  dplyr::mutate(
    prop = n / N_total,
    se = sqrt(prop * (1 - prop) / N_total),
    lower = base::pmax(prop - 1.96 * se, 0),
    upper = base::pmin(prop + 1.96 * se, 1)
  )

# Select Top 10 AEs
ae_plot <- ae_incidence %>%
  dplyr::slice_max(n, n = 10) %>%
  dplyr::arrange(prop) %>%
  dplyr::mutate(AETERM = base::factor(AETERM, levels = AETERM))

plot_2 <- ggplot2::ggplot(ae_plot,
                          ggplot2::aes(x = AETERM, y = prop)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = lower, ymax = upper),
                position = position_dodge(width = 0.5),
                width = 0.2) +
  ggplot2::coord_flip() +
  ggplot2::scale_y_continuous(labels = percent_format(accuracy = 1)) +
  ggplot2::labs(
    title = "Top 10 Most Frequent Adverse Events",
    subtitle = "n = 225 subjects; 95% Clopper-Pearson CIs",
    x = "",
    y = "Percentage of Patients (%)"
  ) +
  ggplot2::theme_minimal()

ggplot2::ggsave(filename = here::here("output", "plot_2.png"), 
       plot = plot_2,
       width = 10,
       height = 6,
       dpi = 300)

# 5. Closing log file

base::cat("\nScript finished successfully at:", base::Sys.time(), "\n")
base::sink()