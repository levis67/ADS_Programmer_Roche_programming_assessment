### Approach

The ADSL dataset was derived using the {admiral} package and SDTM source domains (DM, EX, VS, AE, DS).

Additional derivations implemented:
- Age group categorization (AGEGR9 / AGEGR9N)
- Treatment start datetime with partial time imputation
- Intent-to-treat flag (ITTFL)
- Last known alive date (LSTAVLDT) derived from multiple domains

All derivations follow ADaM implementation principles with traceability to source variables.
