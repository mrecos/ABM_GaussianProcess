from gp_foraging.config import SimulationConfig
from gp_foraging.simulator import run_simulation


def test_gp_ucb_smoke() -> None:
    config = SimulationConfig(
        grid_size=15,
        steps=30,
        seed=5,
        policy="gp_ucb",
        landscape_type="smooth",
    )
    result = run_simulation(config)

    assert len(result.trajectory) == config.steps + 1
    assert len(result.uncertainty) == config.steps
