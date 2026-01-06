"""Agent state and GP belief updates."""

from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import ConstantKernel, RBF, WhiteKernel

from gp_foraging.landscape import Landscape


@dataclass
class ForagerAgent:
    """Agent that observes the landscape and stores a bounded memory."""

    pos: tuple[int, int]
    rng: np.random.Generator
    memory_k: int
    grid_size: int
    obs_X: list[tuple[int, int]] = field(default_factory=list)
    obs_y: list[float] = field(default_factory=list)
    last_seen: dict[tuple[int, int], float] = field(default_factory=dict)
    gp: GaussianProcessRegressor | None = None

    def observe(self, landscape: Landscape, obs_noise_std: float) -> float:
        """Observe the current cell with Gaussian noise and store memory."""
        truth = landscape.sample_truth(*self.pos)
        if obs_noise_std == 0:
            y = truth
        else:
            y = float(self.rng.normal(truth, obs_noise_std))
        self.obs_X.append(self.pos)
        self.obs_y.append(y)
        self.last_seen[self.pos] = y
        if len(self.obs_y) > self.memory_k:
            self.obs_X = self.obs_X[-self.memory_k :]
            self.obs_y = self.obs_y[-self.memory_k :]
        return y

    def fit_gp(self, obs_noise_std: float) -> None:
        """Fit a GP on the current observation window."""
        if len(self.obs_y) < 3:
            self.gp = None
            return
        X = np.asarray(self.obs_X, dtype=float)
        y = np.asarray(self.obs_y, dtype=float)
        X_scaled = _scale_coords(X, self.grid_size)
        kernel = ConstantKernel(1.0) * RBF(length_scale=0.2) + WhiteKernel(
            noise_level=obs_noise_std**2
        )
        self.gp = GaussianProcessRegressor(
            kernel=kernel,
            optimizer=None,
            alpha=1e-6,
            normalize_y=True,
        )
        self.gp.fit(X_scaled, y)

    def predict_cells(
        self, cells: list[tuple[int, int]]
    ) -> tuple[np.ndarray, np.ndarray]:
        """Predict mean and std for candidate cells."""
        if self.gp is None:
            raise ValueError("GP is not fit.")
        if not cells:
            return np.array([]), np.array([])
        X = np.asarray(cells, dtype=float)
        X_scaled = _scale_coords(X, self.grid_size)
        mu, std = self.gp.predict(X_scaled, return_std=True)
        return mu, std


def _scale_coords(coords: np.ndarray, grid_size: int) -> np.ndarray:
    denom = float(grid_size - 1)
    return coords / denom
