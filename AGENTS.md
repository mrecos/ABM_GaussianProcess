# Repository Guidelines

## Project Structure & Module Organization
This repository is being rebuilt as a Python package for Gaussian Process (GP) driven foraging simulations.
- `src/gp_foraging/`: Python package modules (config, landscape, agent, policies, simulator, metrics, plotting, CLI).
- `tests/`: Python tests (to be added alongside features).
- `Doc/`: product specs and implementation plan.
- `img/`: project diagrams used in the README.
- `R_legacy_code/`: legacy R experiments kept for reference.
- `README.md`: project intent and current scope.

## Build, Test, and Development Commands
Python dependencies are defined in `requirements.txt` and `pyproject.toml`.
- Install deps (venv recommended): `pip install -r requirements.txt`
- Run CLI (once implemented): `gp-foraging simulate --steps 200 --grid-size 40`
- Run tests (once implemented): `pytest`

## Coding Style & Naming Conventions
- Language: Python 3.11+.
- Indentation: 4 spaces, no tabs.
- Naming: modules and functions use `snake_case`; classes use `PascalCase`.
- Keep components modular (landscape, agent, policy, simulator) so they can be swapped or tested independently.

## Testing Guidelines
Tests will live under `tests/` and should focus on determinism and small-grid smoke runs.
- Prefer naming like `test_<feature>.py`.
- Keep runs small (e.g., `N=20`, `steps=50`) to keep CI fast.

## Commit & Pull Request Guidelines
- Use clear, descriptive commit messages (1–2 sentences). Example: “add GP-UCB policy scoring”.
- PRs should include: a brief description, modules touched, and any output plots or metrics if behavior changes.

## Configuration Tips
- If you add dependencies, keep `requirements.txt` and `pyproject.toml` in sync.
- Prefer configuration via `SimulationConfig` so CLI flags and tests share defaults.
