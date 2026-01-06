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

    return {
        "policy": result.config.policy,
        "seed": result.seed,
        "steps": result.config.steps,
        "final_cum_reward": float(rewards.sum()),
        "mean_reward": float(rewards.mean()) if rewards.size else 0.0,
        "mean_reward_last_window": float(last_window.mean()) if last_window.size else 0.0,
        "coverage": float(unique_cells) / float(total_cells),
    }


def compute_metrics(results: list[SimulationResult]) -> pd.DataFrame:
    rows = [summarize_run(result) for result in results]
    return pd.DataFrame(rows)


def config_to_dict(result: SimulationResult) -> dict[str, object]:
    """Expose config for logging and outputs."""
    return asdict(result.config)
