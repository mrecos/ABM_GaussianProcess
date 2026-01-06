"""CLI entrypoints for running simulations."""

import json
from pathlib import Path
from typing import Annotated

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
    policy: Annotated[str, typer.Option(help="Policy name")] = "gp_ucb",
    steps: Annotated[int, typer.Option(help="Number of steps")] = 500,
    grid_size: Annotated[int, typer.Option(help="Grid size (N)")] = 50,
    beta: Annotated[float, typer.Option(help="Exploration weight for GP-UCB")] = 1.0,
    runs: Annotated[int, typer.Option(help="Number of runs")] = 1,
    seed: Annotated[int, typer.Option(help="Random seed")] = 42,
    outdir: Annotated[Path, typer.Option(help="Output directory")] = Path("outputs"),
    move_cost_weight: Annotated[
        float, typer.Option(help="Movement cost weight")
    ] = 0.0,
    risk_weight: Annotated[float, typer.Option(help="Risk weight")] = 0.0,
) -> None:
    """Run a single simulation and save plots + metrics."""
    config = SimulationConfig(
        policy=policy,
        steps=steps,
        grid_size=grid_size,
        beta=beta,
        runs=runs,
        seed=seed,
        move_cost_weight=move_cost_weight,
        risk_weight=risk_weight,
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
    policies: Annotated[
        str, typer.Option(help="Comma-separated policy names")
    ] = "random,greedy_noisy,gp_ucb",
    steps: Annotated[int, typer.Option(help="Number of steps")] = 500,
    grid_size: Annotated[int, typer.Option(help="Grid size (N)")] = 50,
    beta: Annotated[float, typer.Option(help="Exploration weight for GP-UCB")] = 1.0,
    runs: Annotated[int, typer.Option(help="Runs per policy")] = 10,
    seed: Annotated[int, typer.Option(help="Random seed")] = 42,
    outdir: Annotated[Path, typer.Option(help="Output directory")] = Path("outputs"),
    move_cost_weight: Annotated[
        float, typer.Option(help="Movement cost weight")
    ] = 0.0,
    risk_weight: Annotated[float, typer.Option(help="Risk weight")] = 0.0,
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
            move_cost_weight=move_cost_weight,
            risk_weight=risk_weight,
        )
        all_results.extend(run_batch(config))

    df = compute_metrics(all_results)
    outdir.mkdir(parents=True, exist_ok=True)
    df.to_csv(outdir / "metrics.csv", index=False)
    save_figure(plot_policy_comparison(df), outdir / "policy_comparison.png")
