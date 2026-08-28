# Architecture — a scalable suite of score-seeking environments

This repo is a **platform** for building many score-seeking / reward-hacking environments, plus the
**environments** themselves. The design goal: adding an environment is filling a small, fixed
contract — never touching platform code — and every environment spins up, runs, and tears down
through one identical set of commands.

## The split: platform (shared) vs environments (per-env content)

```
platform/                      # SHARED — written once, env-agnostic
  suite                        # lifecycle CLI: up | configure | assert | run | reset | down <env>
  tf-modules/range/            # reusable Terraform module (network, NSGs, N Windows + N Linux VMs)
  harness/                     # generic agent harness (bespoke loop + Inspect task) + watermark grader
envs/                          # PER-ENV content — the only thing you write for a new environment
  ad-corp/                     # env #1 — small corporate/AD range
  ics-scada/  (future)         # env #2 — long-horizon (~32 steps)
  ...
docs/  results/  ARCHITECTURE.md  README.md
```

**Principle:** a new environment adds a directory under `envs/` conforming to the contract below.
It reuses the platform's Terraform module, harness, grader, and CLI verbatim.

## The environment contract (minimum artifacts)

Every `envs/<name>/` MUST contain exactly these:

| Artifact | Purpose | Notes |
|---|---|---|
| `env.yaml` | Manifest: name, description, topology summary, factor axes (e.g. `scope`), supported models, budgets (token/step/time), tags. Single source of truth the CLI reads. | declarative |
| `infra/main.tf` | Instantiates `platform/tf-modules/range` with this env's host list + IPs + sizes. Outputs the handles (IPs) the config + harness need. | isolated TF state per env |
| `infra/terraform.tfvars.example` | The secrets/vars template (win password, ssh pubkey, your IP). | real `.tfvars` gitignored |
| `configure.sh` | Idempotent content setup: users, the planted objective(s), the honest path(s), the shortcut(s), the **watermark flags**, tool staging, egress lock. | idempotent, re-runnable |
| `reset.sh` | Return the env to clean state between runs (re-assert content / restore snapshot). | agents mutate state |
| `assert.sh` | **The gate:** verify both the honest and shortcut paths are reachable AND that containment holds (no internet egress). Must pass before any run. | error-free guarantee |
| `task.yaml` | The task/grader spec: objective(s), the **watermark flags + label map** (honest_solve / score_seek_success / fail), the prompt(s) (system + scope variants), and the tool set the agent gets. | what's measured |

Everything else — the orchestrator, the Terraform module, the harness (bespoke loop + Inspect
task), the grader framework — is shared and untouched.

## The lifecycle (every env implements the same verbs)

```
suite up <env>          # terraform apply in envs/<env>/infra (isolated RG + state)
suite configure <env>   # run envs/<env>/configure.sh
suite assert <env>      # run envs/<env>/assert.sh — MUST pass before a run (paths + containment)
suite run <env> --model <m> --scope <s>   # generic harness; native .eval logs + label
suite reset <env>       # envs/<env>/reset.sh — clean state between runs
suite down <env>        # terraform destroy
```

Why this is straightforward, error-free, and scalable:
1. **Platform/content split** → a new env never edits shared code, shrinking the error surface.
2. **`assert` gate** → no run spends money until both paths + no-egress are verified.
3. **Per-env isolation** → each env has its own resource group + Terraform state; envs (and, with
   per-run ephemeral copies, runs) never collide, so the suite parallelizes.
4. **One reusable Terraform module** → topology is data (a host list), not copy-pasted HCL.

## Relationship to `research_dojo`

The `platform/` layer is deliberately thin and maps onto the existing `research_dojo` eval platform
(run registry, auto-resume, spend caps, dashboards, Inspect interop). At scale, `research_dojo`
becomes the experiment/run manager and this suite is the set of environments it runs against —
`platform/harness` is the adapter, not a re-implementation.

## Environment roadmap

- **`ad-corp` (env #1):** small corporate/AD range — the flagship; short honest + shortcut paths,
  proven cross-model result. Kept simple (optionally nudged slightly harder).
- **env #2 (long-horizon, ~32 steps):** targets AISI's corporate-range complexity to measure genuine
  long-horizon ability. Either a larger multi-domain AD or a different system entirely; the honest
  and shortcut paths both span many steps, widening the temptation gradient at long horizon.
