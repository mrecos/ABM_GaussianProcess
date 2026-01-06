"""Plotting utilities for trajectories and metrics."""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def plot_truth_and_path(truth: np.ndarray, trajectory: list[tuple[int, int]]) -> plt.Figure:
    fig, ax = plt.subplots(figsize=(6, 5))
    ax.imshow(truth, origin="lower", cmap="viridis")
    xs = [pos[1] for pos in trajectory]
    ys = [pos[0] for pos in trajectory]
    ax.plot(xs, ys, color="white", linewidth=1.5, alpha=0.9)
    ax.set_title("Truth Landscape + Path")
    ax.set_xlabel("x")
    ax.set_ylabel("y")
    return fig


def plot_visitation_heatmap(
    truth: np.ndarray, trajectory: list[tuple[int, int]]
) -> plt.Figure:
    visits = np.zeros_like(truth, dtype=int)
    for i, j in trajectory:
        visits[i, j] += 1
    fig, ax = plt.subplots(figsize=(6, 5))
    ax.imshow(visits, origin="lower", cmap="magma")
    ax.set_title("Visitation Heatmap")
    ax.set_xlabel("x")
    ax.set_ylabel("y")
    return fig


def plot_learning_curve(rewards: list[float], uncertainty: list[float] | None = None) -> plt.Figure:
    fig, ax = plt.subplots(figsize=(6, 4))
    rewards_arr = np.asarray(rewards, dtype=float)
    cum_reward = rewards_arr.cumsum()
    ax.plot(cum_reward, label="Cumulative Reward")
    ax.set_xlabel("Step")
    ax.set_ylabel("Cumulative Reward")
    ax.set_title("Learning Curve")
    if uncertainty is not None:
        ax2 = ax.twinx()
        ax2.plot(uncertainty, color="tab:orange", alpha=0.7, label="Uncertainty")
        ax2.set_ylabel("Uncertainty")
    return fig


def plot_policy_comparison(df_metrics: pd.DataFrame) -> plt.Figure:
    fig, ax = plt.subplots(figsize=(6, 4))
    policies = sorted(df_metrics["policy"].unique())
    data = [df_metrics[df_metrics["policy"] == p]["final_cum_reward"] for p in policies]
    ax.boxplot(data, labels=policies)
    ax.set_title("Policy Comparison (Final Cumulative Reward)")
    ax.set_xlabel("Policy")
    ax.set_ylabel("Final Cumulative Reward")
    return fig


def save_figure(fig: plt.Figure, path: str | Path) -> None:
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(path, bbox_inches="tight")
