"""Agent state and GP belief updates."""

from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np

from gp_foraging.landscape import Landscape


@dataclass
class ForagerAgent:
    """Agent that observes the landscape and stores a bounded memory."""

    pos: tuple[int, int]
    rng: np.random.Generator
    memory_k: int
    obs_X: list[tuple[int, int]] = field(default_factory=list)
    obs_y: list[float] = field(default_factory=list)

    def observe(self, landscape: Landscape, obs_noise_std: float) -> float:
        """Observe the current cell with Gaussian noise and store memory."""
        truth = landscape.sample_truth(*self.pos)
        if obs_noise_std == 0:
            y = truth
        else:
            y = float(self.rng.normal(truth, obs_noise_std))
        self.obs_X.append(self.pos)
        self.obs_y.append(y)
        if len(self.obs_y) > self.memory_k:
            self.obs_X = self.obs_X[-self.memory_k :]
            self.obs_y = self.obs_y[-self.memory_k :]
        return y
