"""Landscape generation and grid helpers."""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np
from scipy.ndimage import gaussian_filter

from gp_foraging.config import SimulationConfig


@dataclass(frozen=True)
class Landscape:
    truth: np.ndarray
    cost: np.ndarray
    risk: np.ndarray
    N: int

    def sample_truth(self, i: int, j: int) -> float:
        return float(self.truth[i, j])

    def in_bounds(self, i: int, j: int) -> bool:
        return 0 <= i < self.N and 0 <= j < self.N

    def neighbors(self, i: int, j: int, neighborhood: str) -> list[tuple[int, int]]:
        if neighborhood == "von_neumann":
            deltas = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        elif neighborhood == "moore":
            deltas = [
                (-1, -1), (-1, 0), (-1, 1),
                (0, -1), (0, 1),
                (1, -1), (1, 0), (1, 1),
            ]
        else:
            raise ValueError("neighborhood must be 'von_neumann' or 'moore'")
        return [(i + di, j + dj) for di, dj in deltas if self.in_bounds(i + di, j + dj)]


def _normalize_to_unit(arr: np.ndarray) -> np.ndarray:
    min_val = float(arr.min())
    max_val = float(arr.max())
    if max_val - min_val == 0:
        return np.zeros_like(arr)
    return (arr - min_val) / (max_val - min_val)


def make_smooth_landscape(N: int, seed: int, sigma: float = 3.0) -> np.ndarray:
    rng = np.random.default_rng(seed)
    noise = rng.normal(0.0, 1.0, size=(N, N))
    field = gaussian_filter(noise, sigma=sigma)
    return _normalize_to_unit(field)


def make_patchy_landscape(N: int, seed: int, n_peaks: int = 8) -> np.ndarray:
    rng = np.random.default_rng(seed)
    xs = np.linspace(0.0, 1.0, N)
    ys = np.linspace(0.0, 1.0, N)
    xx, yy = np.meshgrid(xs, ys, indexing="ij")
    field = np.zeros((N, N), dtype=float)
    for _ in range(n_peaks):
        cx, cy = rng.uniform(0.0, 1.0, size=2)
        amp = rng.uniform(0.6, 1.2)
        scale = rng.uniform(0.05, 0.2)
        field += amp * np.exp(-((xx - cx) ** 2 + (yy - cy) ** 2) / (2 * scale**2))
    return _normalize_to_unit(field)


def make_landscape(config: SimulationConfig) -> Landscape:
    config.validate()
    if config.landscape_type == "smooth":
        truth = make_smooth_landscape(config.grid_size, config.seed)
    elif config.landscape_type == "patchy":
        truth = make_patchy_landscape(config.grid_size, config.seed)
    else:
        raise ValueError("landscape_type must be 'smooth' or 'patchy'")
    cost = np.zeros_like(truth)
    risk = np.zeros_like(truth)
    return Landscape(truth=truth, cost=cost, risk=risk, N=config.grid_size)
