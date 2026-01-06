"""Configuration dataclasses and defaults."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class SimulationConfig:
    """Simulation configuration for a single run or batch."""

    grid_size: int = 50
    steps: int = 500
    seed: int = 42
    neighborhood: str = "moore"  # "von_neumann" or "moore"
    landscape_type: str = "smooth"  # "smooth" or "patchy"
    obs_noise_std: float = 0.1
    memory_k: int = 50
    beta: float = 1.0
    move_cost_weight: float = 0.0
    risk_weight: float = 0.0
    policy: str = "gp_ucb"  # "random", "greedy_true", "greedy_noisy", "gp_ucb"
    runs: int = 10

    def validate(self) -> None:
        """Validate basic parameter ranges."""
        if self.grid_size <= 1:
            raise ValueError("grid_size must be > 1")
        if self.steps <= 0:
            raise ValueError("steps must be > 0")
        if self.neighborhood not in {"von_neumann", "moore"}:
            raise ValueError("neighborhood must be 'von_neumann' or 'moore'")
        if self.landscape_type not in {"smooth", "patchy"}:
            raise ValueError("landscape_type must be 'smooth' or 'patchy'")
        if self.obs_noise_std < 0:
            raise ValueError("obs_noise_std must be >= 0")
        if self.memory_k <= 0:
            raise ValueError("memory_k must be > 0")
        if self.beta < 0:
            raise ValueError("beta must be >= 0")
        if self.runs <= 0:
            raise ValueError("runs must be > 0")
