# Repository Guidelines

## Project Structure & Module Organization
This repository is a small collection of R scripts demonstrating Gaussian Process (GP) fitting experiments for agent-based models.
- `legancy_R/`: legacy R source directory.
- `legancy_R/GP_fitting/`: GP fitting examples (1D/2D/3D, kernel variants, Cholesky attempts).
- `legancy_R/raster_pkg_random_walk.R`: standalone random-walk example using raster tooling.
- `Dockerfile`: Binder-friendly R image configuration.
- `README.md`: short project overview.
- `AI_Context/`: product spec docs (managed separately).

## Build, Test, and Development Commands
There is no build system or test runner wired up. Typical usage is running scripts directly in R.
- Run a script locally:
- `Rscript legancy_R/GP_fitting/basic_1D_GP_analytical_example.R`
- Start an R session and source a file:
  - `R`
  - `source("legancy_R/GP_fitting/2D_gpe_package_example.R")`
- Optional Docker build for Binder-style environment:
  - `docker build -t abm-gp .`

## Coding Style & Naming Conventions
- Language: R.
- Indentation: follow existing files (mostly 2 spaces). Keep it consistent within a file.
- Naming: scripts use descriptive, snake_case filenames (e.g., `basic_2D_GP_anaytical_example.R`).
- Keep examples self-contained; avoid global side effects outside the script’s scope.

## Testing Guidelines
No automated tests are present.
- If you add tests, keep them under a top-level `tests/` directory and document how to run them in `README.md`.
- Prefer naming like `test_<feature>.R` if using `testthat`.

## Commit & Pull Request Guidelines
Git history shows informal, short commit messages (e.g., “fixed a bug…”, “f”).
- Use clear, descriptive commit messages (1–2 sentences). Example: “fix 2D GP example y-vector construction”.
- PRs should include: a brief description, the script(s) touched, and any output plots or logs if behavior changes.

## Configuration Tips
- If you add dependencies, consider adding an `install.R` so the `Dockerfile` can install packages during image build.
