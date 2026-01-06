"""CLI entrypoints for running simulations."""

from __future__ import annotations

import json
from pathlib import Path

import typer

from gp_foraging.config import SimulationConfig
from gp_foraging.landscape import make_landscape
from gp_foraging.metrics import compute_metrics
from gp_foraging.plotting import (
    plot_learning_curve,
    plot_policy_comparison,
    plot_truth_and_path,
    plot_visitation_heatmap,
    save_figure,
)
from gp_foraging.simulator import run_batch, run_simulation

app = typer.Typer(add_completion=False)


def _write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2))


@app.command()
def simulate(
    policy: str = typer.Option("gp_ucb"),
    steps: int = typer.Option(500),
    grid_size: int = typer.Option(50),
    beta: float = typer.Option(1.0),
    runs: int = typer.Option(1),
    seed: int = typer.Option(42),
    outdir: Path = typer.Option(Path("outputs")),
) -> None:
    """Run a single simulation and save plots + metrics."""
    config = SimulationConfig(
        policy=policy,
        steps=steps,
        grid_size=grid_size,
        beta=beta,
        runs=runs,
        seed=seed,
    )
    if runs > 1:
        results = run_batch(config)
        df = compute_metrics(results)
        save_figure(plot_policy_comparison(df), outdir / "policy_comparison.png")
        df.to_csv(outdir / "metrics.csv", index=False)
        _write_json(outdir / "config.json", config.__dict__)
        return

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
    df = compute_metrics([result])
    df.to_csv(outdir / "metrics.csv", index=False)
    _write_json(outdir / "config.json", config.__dict__)


@app.command()
def compare(
    policies: str = typer.Option("random,greedy_noisy,gp_ucb"),
    steps: int = typer.Option(500),
    grid_size: int = typer.Option(50),
    beta: float = typer.Option(1.0),
    runs: int = typer.Option(10),
    seed: int = typer.Option(42),
    outdir: Path = typer.Option(Path("outputs")),
) -> None:
    """Run multiple policies and save comparison plots + metrics."""
    policy_list = [p.strip() for p in policies.split(",") if p.strip()]
    all_results = []
    for policy in policy_list:
        config = SimulationConfig(
            policy=policy,
            steps=steps,
            grid_size=grid_size,
            beta=beta,
            runs=runs,
            seed=seed,
        )
        all_results.extend(run_batch(config))

    df = compute_metrics(all_results)
    outdir.mkdir(parents=True, exist_ok=True)
    df.to_csv(outdir / "metrics.csv", index=False)
    save_figure(plot_policy_comparison(df), outdir / "policy_comparison.png")
