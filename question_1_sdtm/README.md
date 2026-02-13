### Approach

The DS domain is created using the {sdtm.oak} package following CDISC SDTMIG v3.4 standards.

Key steps included:
- Mapping raw disposition data to SDTM variables
- Applying controlled terminology
- Deriving sequence numbers (DSSEQ)
- Ensuring ISO 8601 date formatting
- Creating study day variable (DSSTDY)

The program was designed to be modular and reproducible, following tidyverse conventions and SDTM best practices.
