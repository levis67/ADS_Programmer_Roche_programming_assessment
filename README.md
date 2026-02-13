## Overview

This repository contains my solutions to the Analytical Data Science Programmer Coding Assessment.

Each question from the assessment as a dedicated folder with the R file used to perform the required task.
The input folder contains the dataset to be used (for question 1).
The output folder contains all the tables and plots output.

Only questions 1 and 3 are done for sake of time. I whish I could do everything in time.
Same with the video presentation of this project.

## Reproducibility

This project uses the `{renv}` and `{here}` packages to ensure a fully reproducible R environment.

The `renv.lock` file included in this repository captures the exact package versions used during development. This guarantees that the analysis can be reproduced with consistent results across different environments.

### How to restore the environment

To reproduce the environment, once the project is cloned:

1. Install `{renv}` if not already installed:

   install.packages("renv")

2. Restore the project library from the lockfile:

   renv::restore()

This will automatically install all required packages with the correct versions.
