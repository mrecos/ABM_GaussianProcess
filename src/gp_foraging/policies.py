"""Movement policies for the forager agent."""

from __future__ import annotations

from gp_foraging.agent import ForagerAgent
from gp_foraging.config import SimulationConfig
from gp_foraging.landscape import Landscape


def select_next_pos(
    agent: ForagerAgent, landscape: Landscape, config: SimulationConfig
) -> tuple[int, int]:
    """Select the next position based on the configured policy."""
    if config.policy == "random":
        return _random_walk(agent, landscape, config)
    raise ValueError(f"Unsupported policy '{config.policy}' in Phase 2")


def _random_walk(
    agent: ForagerAgent, landscape: Landscape, config: SimulationConfig
) -> tuple[int, int]:
    neighbors = landscape.neighbors(*agent.pos, config.neighborhood)
    if not neighbors:
        return agent.pos
    idx = agent.rng.integers(0, len(neighbors))
    return neighbors[int(idx)]
