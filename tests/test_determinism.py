from gp_foraging.config import SimulationConfig
from gp_foraging.simulator import run_simulation


def test_determinism_random_policy() -> None:
    config = SimulationConfig(
        grid_size=20,
        steps=50,
        seed=7,
        policy="random",
        landscape_type="smooth",
    )
    result_a = run_simulation(config)
    result_b = run_simulation(config)

    assert result_a.trajectory == result_b.trajectory
    assert result_a.observations == result_b.observations
    assert result_a.rewards == result_b.rewards
