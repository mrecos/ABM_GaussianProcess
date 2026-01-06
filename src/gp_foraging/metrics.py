"""Metrics computation for simulation outputs."""

from __future__ import annotations

from dataclasses import asdict

import numpy as np
import pandas as pd

from gp_foraging.simulator import SimulationResult


def summarize_run(result: SimulationResult) -> dict[str, float | int | str]:
    rewards = np.asarray(result.rewards, dtype=float)
    trajectory = result.trajectory
    unique_cells = len(set(trajectory))
    total_cells = result.config.grid_size**2
    last_window = rewards[-50:] if len(rewards) >= 50 else rewards
    uncertainty = np.asarray(result.uncertainty, dtype=float)
    finite_uncertainty = uncertainty[np.isfinite(uncertainty)]
    coverage_ratio = float(unique_cells) / float(total_cells)

    return {
        "policy": result.config.policy,
        "seed": result.seed,
        "steps": result.config.steps,
        "final_cum_reward": float(rewards.sum()),
        "mean_reward": float(rewards.mean()) if rewards.size else 0.0,
        "mean_reward_last_window": float(last_window.mean()) if last_window.size else 0.0,
        "coverage": coverage_ratio,
        "mean_uncertainty": float(finite_uncertainty.mean()) if finite_uncertainty.size else float("nan"),
        "final_uncertainty": float(finite_uncertainty[-1]) if finite_uncertainty.size else float("nan"),
        "visitation_entropy": _visitation_entropy(trajectory, result.config.grid_size),
    }


def compute_metrics(results: list[SimulationResult]) -> pd.DataFrame:
    rows = [summarize_run(result) for result in results]
    return pd.DataFrame(rows)


def config_to_dict(result: SimulationResult) -> dict[str, object]:
    """Expose config for logging and outputs."""
    return asdict(result.config)


def _visitation_entropy(trajectory: list[tuple[int, int]], grid_size: int) -> float:
    visits = np.zeros((grid_size, grid_size), dtype=float)
    for i, j in trajectory:
        visits[i, j] += 1.0
    total = visits.sum()
    if total == 0:
        return 0.0
    probs = visits.ravel() / total
    probs = probs[probs > 0]
    return float(-np.sum(probs * np.log(probs)))
