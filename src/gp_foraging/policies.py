"""Movement policies for the forager agent."""

from __future__ import annotations

import numpy as np

from gp_foraging.agent import ForagerAgent
from gp_foraging.config import SimulationConfig
from gp_foraging.landscape import Landscape


def select_next_pos(
    agent: ForagerAgent, landscape: Landscape, config: SimulationConfig
) -> tuple[int, int]:
    """Select the next position based on the configured policy."""
    if config.policy == "random":
        return _random_walk(agent, landscape, config)
    if config.policy == "greedy_true":
        return _greedy_true(agent, landscape, config)
    if config.policy == "greedy_noisy":
        return _greedy_noisy(agent, landscape, config)
    if config.policy == "gp_ucb":
        return _gp_ucb(agent, landscape, config)
    raise ValueError(f"Unsupported policy '{config.policy}'")


def _random_walk(
    agent: ForagerAgent, landscape: Landscape, config: SimulationConfig
) -> tuple[int, int]:
    neighbors = landscape.neighbors(*agent.pos, config.neighborhood)
    if not neighbors:
        return agent.pos
    idx = agent.rng.integers(0, len(neighbors))
    return neighbors[int(idx)]


def _greedy_true(
    agent: ForagerAgent, landscape: Landscape, config: SimulationConfig
) -> tuple[int, int]:
    neighbors = landscape.neighbors(*agent.pos, config.neighborhood)
    if not neighbors:
        return agent.pos
    best = neighbors[0]
    best_score = _true_score(best, landscape, config)
    for cell in neighbors[1:]:
        score = _true_score(cell, landscape, config)
        if score > best_score:
            best = cell
            best_score = score
    return best


def _greedy_noisy(
    agent: ForagerAgent, landscape: Landscape, config: SimulationConfig
) -> tuple[int, int]:
    neighbors = landscape.neighbors(*agent.pos, config.neighborhood)
    if not neighbors:
        return agent.pos
    best = neighbors[0]
    best_score = _noisy_score(agent, best, landscape, config)
    for cell in neighbors[1:]:
        score = _noisy_score(agent, cell, landscape, config)
        if score > best_score:
            best = cell
            best_score = score
    return best


def _true_score(
    cell: tuple[int, int], landscape: Landscape, config: SimulationConfig
) -> float:
    truth = landscape.sample_truth(*cell)
    return float(
        truth
        - config.move_cost_weight * float(landscape.cost[cell])
        - config.risk_weight * float(landscape.risk[cell])
    )


def _noisy_score(
    agent: ForagerAgent,
    cell: tuple[int, int],
    landscape: Landscape,
    config: SimulationConfig,
) -> float:
    observed = agent.last_seen.get(cell, 0.5)
    return float(
        observed
        - config.move_cost_weight * float(landscape.cost[cell])
        - config.risk_weight * float(landscape.risk[cell])
    )


def _gp_ucb(
    agent: ForagerAgent, landscape: Landscape, config: SimulationConfig
) -> tuple[int, int]:
    neighbors = landscape.neighbors(*agent.pos, config.neighborhood)
    if not neighbors:
        return agent.pos
    if len(agent.obs_y) < 3 or agent.gp is None:
        return _random_walk(agent, landscape, config)
    mu, sigma = agent.predict_cells(neighbors)
    scores = (
        mu
        - config.move_cost_weight * np.array([landscape.cost[cell] for cell in neighbors])
        - config.risk_weight * np.array([landscape.risk[cell] for cell in neighbors])
        + config.beta * sigma
    )
    max_score = float(np.max(scores))
    candidates = [idx for idx, score in enumerate(scores) if float(score) == max_score]
    choice = int(agent.rng.choice(candidates))
    return neighbors[choice]
