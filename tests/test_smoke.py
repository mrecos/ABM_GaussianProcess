import numpy as np

from gp_foraging.config import SimulationConfig
from gp_foraging.landscape import make_landscape


def test_landscape_shapes_and_bounds() -> None:
    config = SimulationConfig(grid_size=20, seed=123, landscape_type="smooth")
    landscape = make_landscape(config)

    assert landscape.truth.shape == (20, 20)
    assert landscape.cost.shape == (20, 20)
    assert landscape.risk.shape == (20, 20)
    assert np.all(landscape.truth >= 0.0)
    assert np.all(landscape.truth <= 1.0)

    neighbors = landscape.neighbors(0, 0, "von_neumann")
    assert all(landscape.in_bounds(i, j) for i, j in neighbors)
