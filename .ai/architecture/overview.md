# Architecture intent

This repository uses a framework-neutral AI operating layer. `.ai/manifest.yaml` is the canonical machine configuration. Code and package metadata are authoritative for facts that can be derived automatically; this document records only intent and boundaries.

Compatibility requires an agent host that loads repository instructions or manually attaches them. Raw models do not discover this layer automatically. The generated map is a token-efficient navigation index, not complete semantic or architectural understanding.

## Product reconstruction source

- Read `What Needs To be Done/PROJECT_BLUEPRINT.md` before implementing product functionality. It is the self-contained source of truth for the Kceva Agent OS product, architecture, data model, workflows, security boundaries, reconstruction order, and acceptance criteria.
- Use `What Needs To be Done/AI_REBUILD_PROMPT.md` as the execution contract for building the product from zero.
- Do not assume access to `C:\Users\GCJR\Documents\Code WorkSpace\Agent-System` or any other source repository. All required requirements must be resolved from files inside this repository.
- When generated project facts conflict with the blueprint, current verified code and tests are authoritative for implemented state; the blueprint remains authoritative for unfinished target behavior.

## Boundaries

- Product code must not depend on the AI operating layer.
- `tools/ai-system` may inspect the repository and update derived files, but must not edit product code.
- `.ai/architecture/map.json`, `PROJECT_MAP.md`, and vendor instruction files are generated outputs.
- Framework MCP servers are optional plugins. The project MCP remains usable without them.
- `.ai/integrations/mcp.yaml` is the reviewed MCP registry; `.mcp.json` is generated from enabled entries.
- Secrets, environment values, personal data, and source-file bodies must never be copied into generated indexes.

## Source-specific intent

- `src/routes` currently owns the SvelteKit showcase application.
- `src/lib` currently owns the package's public library API.
- These are current project facts, not assumptions built into the AI system.
