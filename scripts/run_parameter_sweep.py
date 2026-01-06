"""Run a small parameter sweep and save outputs per run."""

from __future__ import annotations

import json
from dataclasses import asdict
from itertools import product
from pathlib import Path

import pandas as pd

from gp_foraging.config import SimulationConfig
from gp_foraging.landscape import make_landscape
from gp_foraging.metrics import compute_metrics
from gp_foraging.plotting import (
    plot_learning_curve,
    plot_truth_and_path,
    plot_visitation_heatmap,
    save_figure,
)
from gp_foraging.simulator import run_simulation


def _float_tag(value: float) -> str:
    return str(value).replace(".", "p")


def _build_sweep(max_runs: int) -> list[dict[str, object]]:
    betas = [1.0]
    noise = [0.1]
    memory_k = [50]
    landscape = ["patchy"]
    neighborhood = ["moore"]
    move_cost_weights = [0.0, 0.2, 0.4, 0.6, 0.8]
    risk_weights = [0.0, 0.1]

    combos = list(
        product(
            betas,
            noise,
            memory_k,
            landscape,
            neighborhood,
            move_cost_weights,
            risk_weights,
        )
    )
    runs: list[dict[str, object]] = []
    for idx, (beta, obs_noise, mem_k, land, neigh, move_w, risk_w) in enumerate(
        combos
    ):
        if len(runs) >= max_runs:
            break
        runs.append(
            {
                "idx": idx,
                "policy": "gp_ucb",
                "beta": beta,
                "obs_noise_std": obs_noise,
                "memory_k": mem_k,
                "landscape_type": land,
                "neighborhood": neigh,
                "move_cost_weight": move_w,
                "risk_weight": risk_w,
            }
        )
    return runs


def main() -> None:
    base_out = Path("outputs")
    base_out.mkdir(parents=True, exist_ok=True)

    sweep = _build_sweep(max_runs=20)
    index_rows = []

    for run in sweep:
        config = SimulationConfig(
            policy=run["policy"],
            beta=float(run["beta"]),
            obs_noise_std=float(run["obs_noise_std"]),
            memory_k=int(run["memory_k"]),
            landscape_type=str(run["landscape_type"]),
            neighborhood=str(run["neighborhood"]),
            move_cost_weight=float(run["move_cost_weight"]),
            risk_weight=float(run["risk_weight"]),
            steps=5000,
            grid_size=50,
            seed=42 + int(run["idx"]),
        )
        tag = (
            f"r{run['idx']:02d}_p-{config.policy}"
            f"_b-{_float_tag(config.beta)}"
            f"_n-{_float_tag(config.obs_noise_std)}"
            f"_k-{config.memory_k}"
            f"_l-{config.landscape_type[0]}"
            f"_nb-{config.neighborhood[0]}"
            f"_mc-{_float_tag(config.move_cost_weight)}"
            f"_rk-{_float_tag(config.risk_weight)}"
        )
        outdir = base_out / tag
        outdir.mkdir(parents=True, exist_ok=True)

        result = run_simulation(config)
        landscape = make_landscape(config)
        save_figure(plot_truth_and_path(landscape.truth, result.trajectory), outdir / "path.png")
        save_figure(
            plot_visitation_heatmap(landscape.truth, result.trajectory),
            outdir / "visitation_heatmap.png",
        )
        save_figure(
            plot_learning_curve(result.rewards, result.uncertainty),
            outdir / "learning_curve.png",
        )

        metrics_df = compute_metrics([result])
        metrics_df.to_csv(outdir / "metrics.csv", index=False)
        (outdir / "config.json").write_text(json.dumps(asdict(config), indent=2))

        index_rows.append({"run": tag, **asdict(config)})

    pd.DataFrame(index_rows).to_csv(base_out / "sweep_index.csv", index=False)


if __name__ == "__main__":
    main()
