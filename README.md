## Overview

This repository contains my solutions to the Analytical Data Science Programmer Coding Assessment.

Only questions 1 and 3 are done for sake of time. I whish I could do everything in time.

## Reproducibility

This project uses the `{renv}` package to ensure a fully reproducible R environment.

The `renv.lock` file included in this repository captures the exact package versions used during development. This guarantees that the analysis can be reproduced with consistent results across different environments.

### How to restore the environment

To reproduce the environment, once the project is cloned:

1. Install `{renv}` if not already installed:

   install.packages("renv")

2. Restore the project library from the lockfile:

   renv::restore()

This will automatically install all required packages with the correct versions.
