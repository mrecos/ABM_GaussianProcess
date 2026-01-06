![ABM GP Abstract](img/ABM_GP_Abstract.png)

# ABM Gaussian Process Foraging (MVP)

This repository is being rebuilt as a Python package that simulates Bayesian optimal foraging on a 2D grid. The core idea is to compare a GP-driven agent (exploration vs. exploitation via UCB) against simple baselines on unknown resource landscapes. The MVP focuses on a single agent, reproducible runs, and clear visual/metric outputs.

## Project Intent
- Model a latent resource landscape on a raster-like grid (numpy array).
- Let an agent observe noisy samples, fit a Gaussian Process belief, and choose moves via a UCB rule.
- Compare against baseline behaviors (random walk, greedy on noisy samples, optional greedy on true values).
- Produce plots and metrics that reveal learning, exploration, and trajectory structure.

## Scope (MVP)
- 2D square grid, 4- or 8-neighborhood movement.
- Two landscape generators: smooth (Gaussian-filtered noise) and patchy (Gaussian peaks).
- GP belief model using scikit-learn with fixed hyperparameters for speed.
- Outputs: trajectory plot, visitation heatmap, learning curve, and policy comparisons.

## Planned Package Layout
The Python implementation will live under `src/gp_foraging/` with modules for configuration, landscape generation, agent/policies, simulation, metrics, plotting, and a CLI. Legacy R experiments live in `legancy_R/`.

## Status
Product spec and build plan live in `AI_Context/`. Implementation is in progress as we transition to the new Python package.

## Development Setup
- Create a virtual environment (recommended).
- Install dependencies: `pip install -r requirements.txt`
- Run tests: `pytest`
