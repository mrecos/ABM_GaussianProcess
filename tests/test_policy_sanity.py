from gp_foraging.config import SimulationConfig
from gp_foraging.simulator import run_batch


def _mean_final_cum_reward(results) -> float:
    return sum(sum(r.rewards) for r in results) / len(results)


def test_greedy_true_beats_random_on_average() -> None:
    base = dict(grid_size=20, steps=60, seed=11, landscape_type="smooth", runs=6)

    random_results = run_batch(SimulationConfig(policy="random", **base))
    greedy_results = run_batch(SimulationConfig(policy="greedy_true", **base))

    mean_random = _mean_final_cum_reward(random_results)
    mean_greedy = _mean_final_cum_reward(greedy_results)

    assert mean_greedy >= mean_random - 1e-6
