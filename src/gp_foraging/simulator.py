"""Simulation loop and batch runner."""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

from gp_foraging.agent import ForagerAgent
from gp_foraging.config import SimulationConfig
from gp_foraging.landscape import Landscape, make_landscape
from gp_foraging.policies import select_next_pos


@dataclass
class SimulationResult:
    trajectory: list[tuple[int, int]]
    observations: list[float]
    true_values: list[float]
    rewards: list[float]
    config: SimulationConfig
    seed: int


def _init_agent(landscape: Landscape, config: SimulationConfig) -> ForagerAgent:
    rng = np.random.default_rng(config.seed)
    start_i = int(rng.integers(0, landscape.N))
    start_j = int(rng.integers(0, landscape.N))
    return ForagerAgent(pos=(start_i, start_j), rng=rng, memory_k=config.memory_k)


def run_simulation(config: SimulationConfig) -> SimulationResult:
    config.validate()
    landscape = make_landscape(config)
    agent = _init_agent(landscape, config)

    trajectory = [agent.pos]
    observations: list[float] = []
    true_values: list[float] = []
    rewards: list[float] = []

    for _ in range(config.steps):
        obs = agent.observe(landscape, config.obs_noise_std)
        true_val = landscape.sample_truth(*agent.pos)
        reward = (
            true_val
            - config.move_cost_weight * float(landscape.cost[agent.pos])
            - config.risk_weight * float(landscape.risk[agent.pos])
        )
        observations.append(obs)
        true_values.append(true_val)
        rewards.append(float(reward))

        next_pos = select_next_pos(agent, landscape, config)
        agent.pos = next_pos
        trajectory.append(agent.pos)

    return SimulationResult(
        trajectory=trajectory,
        observations=observations,
        true_values=true_values,
        rewards=rewards,
        config=config,
        seed=config.seed,
    )
