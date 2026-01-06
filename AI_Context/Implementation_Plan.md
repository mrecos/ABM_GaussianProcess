# Implementation Plan (Iterative)

This plan builds the MVP in small, testable increments. Each step produces a working baseline and isolates the next change so we can validate behavior before stacking complexity. Keep modules independent and wired through small interfaces to make it easy to swap policies, landscapes, or belief models.

## Phase 1: Core Grid + Determinism
- Implement `config.py` with a `SimulationConfig` dataclass and seed handling.
- Implement `landscape.py` with grid helpers, neighbor lookup, and a single smooth generator.
- Add a tiny `tests/test_smoke.py` that builds a landscape and checks shapes and bounds.
- Goal: deterministic, fast grid generation and neighborhood mechanics.

## Phase 2: Minimal Agent + Random Policy
- Implement `agent.py` with position, RNG, and noisy observation (no GP yet).
- Implement `policies.py` with `random` policy only.
- Implement `simulator.py` to run a loop and return trajectory + observations.
- Add `tests/test_determinism.py` to confirm repeatable trajectories with a fixed seed.
- Goal: stable simulation loop with a baseline agent.

## Phase 3: Baseline Policies + Metrics
- Add `greedy_noisy` and `greedy_true` policies (guarded for realism).
- Implement `metrics.py` for cumulative reward, coverage, and basic summaries.
- Add `tests/test_policy_sanity.py` with small batch comparisons.
- Goal: comparable baselines and reproducible metrics.

## Phase 4: GP Belief Model (Modular)
- Add GP belief updates behind a clear interface in `agent.py` (fit/predict). Keep kernels fixed.
- Implement `gp_ucb` policy in `policies.py` using only the public agent/landscape APIs.
- Add a small GP-specific smoke test (e.g., predictable output shapes).
- Goal: GP-UCB runs end-to-end without touching other modules.

## Phase 5: Plotting + CLI
- Implement plotting helpers in `plotting.py` for path, heatmap, and learning curve.
- Implement CLI in `cli.py` with `simulate` and `compare` commands and an output dir contract.
- Add a `tests/test_smoke_cli.py` if feasible with tiny runs and temp output.
- Goal: one-command runs that generate metrics + plots.

## Phase 6: Refinement + Modularity
- Add patchy landscape and optional risk/cost grids as separate generators.
- Introduce a simple `interfaces` note in each module docstring to keep APIs stable.
- Document how to add new policies without touching the simulator loop.
- Goal: experimentation ready; swap components without regressions.

## Testing Strategy (Each Phase)
- Keep tests tiny (N=10–20, steps=20–50).
- Validate determinism for fixed seeds.
- Log minimal metrics to spot regressions.
- Run only the new tests each phase before merging changes.
