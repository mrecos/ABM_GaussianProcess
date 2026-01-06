MVP Product Specification

# Product Spec - MVP — Bayesian Optimal Foraging on a Raster via GP Cognition (Python)

### 0) Objective

Build a minimal, reproducible simulation that tests whether a forager agent equipped with a **Gaussian Process belief model** over an unknown spatial resource landscape can outperform and/or behave differently than baseline agents, by balancing **exploitation (posterior mean)** and **exploration (posterior uncertainty)**.

The MVP should support:

- A **latent “true” landscape** Z(s)Z(s)Z(s) on a raster grid.
    
- An agent that observes noisy samples of Z(s)Z(s)Z(s), updates a GP posterior, and chooses movements using a UCB-like rule.
    
- Baseline agents (random walk; greedy local; greedy on noisy samples).
    
- Metrics and plots that show learning, exploration, and emergent movement patterns.
    

No GIS stack required; use numpy grids for speed/simplicity. Optional later: rasterio.

---

## 1) Scope (MVP)

### In scope

- 2D square grid environment (N×N).
    
- Landscape generation (at least two options):
    
    1. Smooth random field generated via Gaussian-filtered noise.
        
    2. “Patchy” field (e.g., multi-Gaussian blobs / random peaks).
        
- Movement is to 4- or 8-neighborhood cells.
    
- Observation noise (Gaussian) + optional “observation radius” (agent observes only its cell for MVP).
    
- GP belief model for agent:
    
    - Use sklearn GaussianProcessRegressor with fixed kernel hyperparameters (initially).
        
    - Update GP using a bounded memory window (last k observations).
        
    - Predict mean/std on candidate neighbor cells each step.
        
- Movement policy:
    
    - UCB: score = mu - cost + beta * sigma - risk_weight * risk
        
    - For MVP, cost and risk can be optional grids defaulting to zero.
        
- Outputs:
    
    - Trajectory plot over truth landscape.
        
    - Heatmap of visitation frequency.
        
    - Learning curve: cumulative reward vs step; mean uncertainty sampled vs step.
        
    - Compare policies across multiple seeds/runs.
        

### Out of scope (for MVP)

- Multi-agent interaction/social learning.
    
- Depletion/regeneration dynamics (can stub an interface).
    
- Full observation operators (viewshed, etc.).
    
- Hyperparameter optimization every step.
    
- Calibration/emulation over ABM parameters.
    

---

## 2) Non-Functional Requirements

- Runtime: single run (T=500 steps, N=50, k=50) should complete in <10 seconds on laptop.
    
- Determinism: results reproducible given seed.
    
- Packaging: repo-style structure with requirements and a single CLI entry.
    
- Minimal dependencies and clean code.
    

---

## 3) Tech Stack

- Python 3.11+
    
- numpy
    
- scipy (for gaussian_filter)
    
- scikit-learn (GaussianProcessRegressor, kernels)
    
- matplotlib
    
- pandas (optional for metrics tables)
    
- typer or argparse for CLI (typer preferred)
    

Pinned deps in `requirements.txt` or `pyproject.toml`.

---

## 4) Repository Structure

`gp_foraging_mvp/   README.md   requirements.txt   src/     gp_foraging/       __init__.py       config.py       landscape.py       policies.py       agent.py       simulator.py       metrics.py       plotting.py       cli.py   tests/     test_smoke.py     test_determinism.py     test_policy_sanity.py   notebooks/ (optional)     demo.ipynb`

---

## 5) Core Data Model

### 5.1 Config

`config.py`

- `SimulationConfig` dataclass with defaults:
    
    - `grid_size: int = 50`
        
    - `steps: int = 500`
        
    - `seed: int = 42`
        
    - `neighborhood: str = "moore"` # "von_neumann" or "moore"
        
    - `landscape_type: str = "smooth"` # "smooth" or "patchy"
        
    - `obs_noise_std: float = 0.1`
        
    - `memory_k: int = 50` # GP training window
        
    - `beta: float = 1.0` # exploration weight
        
    - `move_cost_weight: float = 0.0`
        
    - `risk_weight: float = 0.0`
        
    - `policy: str = "gp_ucb"` # "random", "greedy_true", "greedy_noisy", "gp_ucb"
        
    - `runs: int = 10` # replicate runs for comparison
        

### 5.2 Landscape

`landscape.py`

- `Landscape` dataclass:
    
    - `truth: np.ndarray` shape (N, N)
        
    - `cost: np.ndarray` shape (N, N) default zeros
        
    - `risk: np.ndarray` shape (N, N) default zeros
        
    - `N: int`
        
- Methods:
    
    - `sample_truth(i, j) -> float`
        
    - `in_bounds(i, j) -> bool`
        
    - `neighbors(i, j, neighborhood) -> list[tuple[int,int]]`
        

Landscape generation functions:

- `make_smooth_landscape(N, seed, sigma=3.0) -> np.ndarray`
    
    - generate white noise then gaussian_filter
        
    - normalize to [0,1]
        
- `make_patchy_landscape(N, seed, n_peaks=8) -> np.ndarray`
    
    - place random gaussian peaks, sum, normalize
        
- `make_landscape(config) -> Landscape`
    

---

## 6) Agent + Belief Model

### 6.1 Agent State

`agent.py`

- `ForagerAgent` class:
    
    - attributes:
        
        - `pos: tuple[int,int]`
            
        - `rng: np.random.Generator`
            
        - `obs_X: list[tuple[int,int]]` # observed locations
            
        - `obs_y: list[float]` # observed values (noisy)
            
        - `memory_k: int`
            
        - `gp: GaussianProcessRegressor` # sklearn
            
    - methods:
        
        - `observe(landscape, obs_noise_std) -> float`
            
            - y = truth[pos] + Normal(0, obs_noise_std)
                
            - append to obs; trim to last k
                
            - return y
                
        - `fit_gp() -> None`
            
            - fit gp on current memory window
                
            - transform X from (i,j) to continuous coords (i/(N-1), j/(N-1)) for scaling
                
        - `predict_cells(cells: list[(i,j)]) -> (mu: np.ndarray, sigma: np.ndarray)`
            
            - return posterior mean and std for candidate cells
                

### 6.2 GP Kernel Choice (fixed for MVP)

Use:

- `kernel = ConstantKernel(1.0) * RBF(length_scale=0.2) + WhiteKernel(noise_level=obs_noise_std**2)`
    
- Set `optimizer=None` (no hyperparameter optimization) for speed/stability.
    
- Optionally allow `optimizer="fmin_l_bfgs_b"` in config as advanced toggle, but default off.
    

---

## 7) Policies (Movement Decision Rules)

`policies.py`  
Implement a `select_next_pos(agent, landscape, config) -> tuple[int,int]` with per-policy behavior:

### 7.1 Random Walk

- Choose uniformly from neighbors.
    

### 7.2 Greedy True (Upper bound baseline)

- Choose neighbor maximizing `truth - move_cost_weight*cost - risk_weight*risk`.
    
- This is not “realistic” but provides a ceiling.
    

### 7.3 Greedy Noisy (Classic myopic)

- Agent observes only current cell; maintains a simple map of last-seen values for visited cells.
    
- For each neighbor:
    
    - if visited: use stored last observed value
        
    - else: assume 0.5 (or global mean prior)
        
- Choose argmax of that heuristic (no uncertainty term).
    

### 7.4 GP-UCB (Main contribution)

For candidate neighbor cells `C`:

- get `(mu, sigma)` from agent GP
    
- compute:
    
    - `score = mu - move_cost_weight*cost[cell] - risk_weight*risk[cell] + beta*sigma`
        
- choose argmax score
    
- tie-break randomly using agent rng
    

Important: if agent has fewer than 3 observations, fallback to random or greedy_noisy to avoid ill-conditioned GP.

---

## 8) Simulator

`simulator.py`

- `SimulationResult` dataclass:
    
    - `trajectory: list[(i,j)]` length steps+1
        
    - `observations: list[float]` length steps
        
    - `true_values: list[float]` length steps
        
    - `rewards: list[float]` length steps # define reward as truth[pos] - costs/risk
        
    - `uncertainty: list[float]` length steps # sigma at chosen step (or current pos)
        
    - `config: SimulationConfig`
        
    - `seed: int`
        
- `run_simulation(config: SimulationConfig) -> SimulationResult`
    
    - init RNG
        
    - build landscape
        
    - init agent at random start (or fixed center; choose one, default random)
        
    - loop t in 0..steps-1:
        
        1. agent.observe()
            
        2. agent.fit_gp() (if enough obs)
            
        3. choose next via policy
            
        4. update position
            
        5. log metrics
            
- `run_batch(config) -> list[SimulationResult]`
    
    - run `config.runs` with seeds = seed + run_idx
        

---

## 9) Metrics

`metrics.py`  
Compute at least:

- cumulative reward per run
    
- mean reward last 50 steps
    
- exploration indicator: mean sigma at visited cells per step; or mean sigma at chosen move
    
- spatial coverage: unique cells visited / total
    
- path efficiency: average step-to-step change in truth value
    
- entropy of visitation heatmap (optional)
    

Return a pandas DataFrame for batch comparisons:

- columns: policy, run, seed, final_cum_reward, coverage, mean_sigma, etc.
    

---

## 10) Plotting

`plotting.py`  
Required plots:

1. `plot_truth_and_path(truth, trajectory)`:
    
    - imshow truth + overlay path polyline
        
2. `plot_visitation_heatmap(truth, trajectory)`:
    
    - count visits per cell, imshow counts
        
3. `plot_learning_curve(rewards, uncertainty)`:
    
    - cumulative reward vs step (line)
        
    - uncertainty vs step (second y-axis or separate plot)
        
4. `plot_policy_comparison(df_metrics)`:
    
    - boxplot of final cumulative reward by policy
        

---

## 11) CLI

`cli.py` using typer:  
Commands:

- `simulate --policy gp_ucb --steps 500 --grid-size 50 --beta 1.0 --runs 1 --seed 42 --outdir outputs/`
    
- `compare --policies random,greedy_noisy,gp_ucb --runs 20 --seed 42 --outdir outputs/`
    

Output files:

- `outputs/config.json`
    
- `outputs/metrics.csv`
    
- `outputs/*.png`
    

---

## 12) README

Explain:

- research question (OFT under uncertainty via GP cognition)
    
- how to run a single simulation and comparison batch
    
- interpretation of plots
    
- how to adjust beta/memory_k/noise
    

---

## 13) Tests (Minimal)

### `test_smoke.py`

- run `run_simulation` with small config N=20, steps=50 and assert:
    
    - trajectory length correct
        
    - no exceptions
        

### `test_determinism.py`

- run twice with same seed and assert identical trajectories for deterministic policies (gp_ucb should be deterministic given fixed optimizer=None and tie-break controlled by rng)
    

### `test_policy_sanity.py`

- ensure greedy_true ≥ random in expectation over small batch (allow some tolerance; run multiple seeds)
    

---

## 14) Acceptance Criteria (What “done” means)

1. `compare` produces metrics and plots for at least policies: random, greedy_noisy, gp_ucb (greedy_true optional).
    
2. In a batch of e.g., 20 runs on smooth landscapes:
    
    - gp_ucb shows higher median cumulative reward than random and greedy_noisy for at least one non-trivial parameter setting (beta ~ 0.5–2.0, memory_k ~ 25–100).
        
3. Plots clearly show:
    
    - gp_ucb explores uncertain regions early (higher sigma early, decreasing over time),
        
    - visitation patterns differ from baselines (not pure diffusion).
        

---

## 15) Implementation Notes / Guardrails

- Normalize coordinates for GP input to [0,1] range.
    
- Use bounded memory window to keep GP fit fast.
    
- Avoid refitting GP if obs set unchanged (optional micro-optimization).
    
- Ensure stable GP by:
    
    - adding small jitter (alpha) if needed (sklearn has `alpha=`).
        
- Consider starting agent at center for comparability across runs; make start strategy configurable.
    

---

## 16) Future Extensions (Non-MVP, just placeholders)

- Depletion/regeneration: truth becomes Z_t updated by visits
    
- Observation constraints: visibility radius, terrain barriers
    
- Multiple agents and knowledge sharing (belief pooling)
    
- Surveyor agents for discovery bias (archaeological record generation)
    
- Emulator over ABM parameters
    

---

# Suggested Defaults for Initial Demo

- N=60, steps=800, obs_noise_std=0.15, memory_k=75, beta=1.0, landscape=smooth, neighborhood=moore
    
- Compare policies with runs=30