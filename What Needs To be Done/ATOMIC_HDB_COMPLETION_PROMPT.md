# Atomic DSB Documentation — Autonomous Completion Prompt

## Mission

Continue and finish the existing documentation repository at:

`C:\Users\GCJR\Documents\Code WorkSpace\Atomic HDB`

Do not rebuild it from scratch. Preserve verified work, the existing information architecture, the Atomic DSB visual language, German source content, English localization, and all intentional Docusaurus conventions. Work autonomously for as long as useful, in small validated phases. Do not stop merely to report progress while safe, evidence-backed work remains.

The repository documents **Atomic DSB (Atomic Design System Builder)**: a product concept intended to make design systems a shared source of truth for Product, UX/UI, Development, and Marketing by connecting design tokens, components, maturity/status, documentation, and exports.

## Non-negotiable operating rules

1. Inspect before editing. Never guess file contents, repository state, product facts, research results, deployment coordinates, credentials, or completed work.
2. Preserve existing design and content conventions unless a concrete defect requires change.
3. Treat German files under `docs/` as the canonical content source and maintain corresponding English files under `i18n/en/docusaurus-plugin-content-docs/current/`.
4. Do not invent interviews, usability-test results, stakeholder decisions, measured outcomes, dates, production URLs, repositories, credentials, or legal conclusions.
5. Derived summaries may use existing evidence, but clearly label assumptions, proposals, targets, and unvalidated hypotheses.
6. Do not replace detailed completed pages with generic prose. Preserve useful citations, tables, links, personas, research, token documentation, and live examples.
7. Remove Docusaurus starter/template content only after proving it is unreferenced and unrelated to Atomic DSB.
8. Never weaken broken-link checks, type checks, security warnings, accessibility requirements, or localization parity to make validation pass.
9. Do not commit, push, deploy, change remote repositories, or create real credentials unless explicitly authorized.
10. Do not create a new password or pretend client-side password protection is secure.
11. Do not modify files outside the Atomic HDB repository.
12. Keep the working tree understandable. Remove temporary scripts, logs, screenshots, build artifacts, and experiments before completion; retain useful permanent validation tooling.
13. Read exact errors, identify the root cause, fix only the root cause, and rerun the failing command.
14. Preserve unrelated user changes. Do not reset, revert, or overwrite them.

## Verified repository model

The project is a static bilingual documentation website built with Docusaurus, React, TypeScript, Markdown/MDX, Infima, and an Atomic DSB token layer. Exact dependency versions belong to `package.json` and `package-lock.json`; do not duplicate them in new documentation.

Important repository behavior:

- German is the default locale in `docs/`.
- English mirrors the product documentation under `i18n/en/docusaurus-plugin-content-docs/current/`.
- The product documentation currently contains 72 German product pages and 73 English pages; English has one extra `02-research/interview-questions.md` that must be inspected and either intentionally mapped or removed.
- Sidebar navigation is manually defined in `sidebars.ts`.
- Numbered source directories affect filesystem ordering; sidebar Doc IDs omit number prefixes.
- New pages require both locale files and a deliberate sidebar entry unless intentionally reachable only by direct link.
- Cross-locale direct links can break per-locale builds; use locale-neutral internal links and the language switcher.
- Docusaurus/MDX admonitions use bracketed titles such as `:::info[Title]`.
- Token CSS load order is intentional: raw tokens, Infima mapping, then component styles.
- `src/theme/Root.tsx` wraps the site with a client-side password gate.
- `src/theme/DocItem/Layout/index.tsx` adds a copy-page control to documentation pages.
- The current homepage is intentionally compact and links into the documentation.
- `onBrokenLinks` is intentionally strict.

## Product truth to preserve

Atomic DSB addresses fragmented design-system knowledge across Figma, Storybook, Jira, Confluence/Notion, repositories, and individual team knowledge. Its intended value is a role-aware shared source that connects:

- Design tokens: primitive, semantic, and component levels.
- Components: structure, variants, states, props, accessibility, usage, and code references.
- Maturity/status: draft, review, approved, deprecated, and needs-update states.
- Product requirements and component availability.
- Documentation, assets, exports, change history, and versioning.
- Different information needs for Product, UX/UI, Development, and Marketing.

The product vision, strategy, market analysis, OKRs, roadmap, research plan, two completed interviews, research insights, four detailed personas, prioritization matrix, token CSS, and button implementation are meaningful existing evidence. Use them as sources; do not replace them with imagined product facts.

The actual product application is a separate repository. This repository documents the product and must not claim that proposed Atomic DSB application features are implemented merely because they are described here.

## Current evidence and gaps

Substantial content already exists in:

- Start: project overview, product definition, problem, audiences.
- Strategy: vision, market factors, competition, UVP, OKRs, roadmap.
- Research: plan, survey, interview guide, two completed interviews, consolidated insights.
- Personas: four detailed role-based personas.
- Requirements: a detailed prioritization matrix.
- Design system: real token CSS and a live button example.
- Technical: repository setup, proposed architecture/data model, and deployment notes.
- Root documentation: German and English README files plus onboarding notes.

Major placeholders or incomplete areas include:

- Documentation overview and usage guidance.
- Strategic prioritization, stakeholder management, and internal pitch.
- Interview results summary, pain points, desires, opportunity areas, and usability-test plan/results distinction.
- Personas overview and all role-specific user flows.
- User stories, epics, PRD, MVP scope, feature scope, acceptance criteria, and requirements roadmap.
- Most design-system reference pages: token taxonomy, Figma variables, primitives, semantic tokens, components, variants, guidelines, and decision logic.
- Decision log, open questions, risks, assumptions, and scope changes.
- Meeting pages and meeting template.
- Glossary.
- Many corresponding English pages.
- Docusaurus sample tutorials, sample blog content, sample illustrations/components, placeholder social image, and placeholder deployment configuration.
- A client-side password gate with a documented placeholder password; this is deterrence, not confidentiality.

## Required execution plan

### Phase 0 — Baseline and evidence inventory

1. Read `README.md`, `README.en.md`, `ONBOARDING.md`, `docusaurus.config.ts`, `sidebars.ts`, `package.json`, all custom source files, and all German product documentation.
2. Inspect the current Git status without resetting anything. Record pre-existing changes and avoid overwriting them.
3. Build a page inventory containing:
   - German path.
   - English counterpart.
   - Sidebar membership.
   - Status: complete, partial, placeholder, template, or obsolete.
   - Evidence sources that can support completion.
4. Identify unreferenced template assets and custom components before deleting anything.
5. Run the existing baseline commands and record exact outcomes:

```text
npm ci
npm run typecheck
npm run build
```

If `npm ci` would destroy uncommitted dependency work, inspect first and use the safest equivalent. Do not conceal baseline failures.

### Phase 1 — Remove unrelated Docusaurus starter content

Inspect references, then remove starter material that is not part of Atomic DSB:

- `docs/intro.mdx`.
- `docs/tutorial-basics/`.
- `docs/tutorial-extras/` and their tutorial images.
- Sample blog posts, authors, tags, and blog translations when the product has no intentional blog.
- `HomepageFeatures` and `undraw_docusaurus_*` assets if unreferenced.
- Docusaurus sample social imagery if replaced by an Atomic DSB asset.

If the blog is removed, disable it deliberately in Docusaurus configuration and remove obsolete generated translation keys only through a safe, reproducible process. Do not leave dead navigation, routes, imports, or assets.

Do not remove persona images, Atomic DSB logos/signets, favicon assets, token files, password-gate assets, or content-linked media.

### Phase 2 — Resolve configuration without guessing

Fix configuration values only when their true values are available from repository evidence or explicit user input:

- Production `url`.
- `baseUrl`.
- GitHub organization/user and project name.
- Edit-page URL.
- Social card.

If a value is not known, do not invent it. Record it in the Open Questions page and keep deployment explicitly blocked rather than shipping Docusaurus sample values.

Preserve strict broken-link behavior, bilingual configuration, token CSS order, and theme wrappers.

### Phase 3 — Complete canonical German content from existing evidence

Write concise, useful documentation. Avoid filler such as “This page describes X” or “content will be added.” Prefer links to authoritative pages over duplicated long passages.

#### Start

- Complete documentation overview: map each section, its audience, and its authority.
- Complete how-to-use guidance: reading paths for Product, UX/UI, Development, Marketing, and contributors.

#### Strategy

- Complete strategic prioritization using the existing vision, OKRs, roadmap, research, and requirements matrix.
- Complete stakeholder management with roles, influence/interest, responsibilities, evidence needs, and communication cadence. Do not invent named people.
- Create an internal pitch based only on the existing problem, vision, audience, research, UVP, roadmap, and MVP direction.

#### Research

- Summarize the two completed interviews in Interview Results without inventing participants or statistics.
- Derive Pain Points, User Desires, and Opportunity Areas from the actual interview and research-insight pages, with traceable links.
- Turn Usability Testing into an honest test plan unless executed evidence exists. Separate planned tasks and target metrics from observed results.
- Keep the empty interview file only if it is deliberately presented as a reusable template; rename/title it clearly and ensure both locales match.

#### Personas and user flows

- Complete the personas overview by comparing the four existing personas and their role-specific needs.
- Create evidence-backed flows for Product Manager, UX/UI Designer, Developer, and Marketing/Brand.
- Each flow must include trigger, goal, prerequisites, main steps, decisions, failure/empty states, expected information, and success signal.
- Connect flows to relevant Atomic DSB capabilities without claiming those capabilities are already implemented.

#### Requirements

Use strategy, research, personas, flows, OKRs, roadmap, and the prioritization matrix to complete:

- User stories grouped by role and capability.
- Epics with goal, scope, exclusions, dependencies, and evidence.
- PRD with problem, objective, users, proposed scope, non-goals, functional requirements, quality attributes, risks, open questions, and measurable acceptance criteria.
- MVP scope with Must/Should/Later boundaries.
- Feature scope distinguishing documentation concept, prototype, MVP, and later platform vision.
- Acceptance criteria written in testable language.
- Requirements-level Now/Next/Later roadmap aligned with, but not duplicating, the strategic roadmap.

Do not turn P4 ideas into MVP commitments. Do not invent technical implementation in the separate product repository.

#### Design system

Derive documentation from the actual token JSON/CSS and button implementation:

- Token architecture and naming.
- Figma-variable mapping and the fact that sync is currently manual.
- Primitive and semantic token references.
- Component documentation model.
- Button variants, sizes, states, accessibility, usage, and live examples.
- General component variants/states guidance.
- Design-system guidelines and component decision logic.

Do not claim automated token generation or sync if it does not exist. Resolve contradictory comments such as “generated directly” when the repository documents manual transfer.

#### Technical and decisions

- Keep repository setup concise and authoritative; do not duplicate package versions outside package files.
- Clearly distinguish this documentation website from the separate Atomic DSB application.
- Label the application data model as a proposal, not implemented schema.
- Populate Decision Log only with decisions supported by repository evidence: bilingual docs, German canonical source, manual sidebar, manual token transfer, strict links, target hosting direction, and password-gate limitation.
- Populate Risks and Assumptions from existing evidence.
- Populate Open Questions with unresolved deployment, confidentiality, source-of-truth, product-repository alignment, token sync, MVP scope, and ownership questions.
- Record scope changes only when evidence exists; otherwise provide a clean template and state that no verified entries are available.

#### Meetings and glossary

- Do not invent meeting history.
- Convert meeting pages into useful templates/indexes and clearly state when no verified notes exist.
- Build the glossary from terms actually used across the documentation, with concise definitions and links to canonical pages.

### Phase 4 — English parity

After each German section is stable:

1. Create or update the exact English counterpart.
2. Preserve meaning, hierarchy, links, tables, warnings, and status distinctions.
3. Translate navigation/category labels where required.
4. Do not leave “Placeholder – not yet written” when German content is complete.
5. Inspect the extra English `02-research/interview-questions.md`; remove it if obsolete or create an intentional German counterpart and sidebar mapping if it has unique value.
6. Ensure every canonical German product page has exactly one English counterpart and no orphan English product pages remain.

### Phase 5 — Security and deployment decision gate

The current client-side password gate cannot protect confidential content because the static JS bundles contain the documentation. Treat this as a hard architectural limitation.

Complete all safe local work, but do not declare production deployment ready until one explicit decision is made:

- **Public documentation:** remove the misleading password gate and publish only content approved for public access.
- **Private documentation:** use hosting with real server/edge authentication and authorization; do not rely on GitHub Pages or a client-side hash.
- **Low-security deterrence:** retain the gate only with explicit documentation that it is not confidentiality.

Do not choose on the user's behalf. Do not generate or commit a replacement password. Remove the literal placeholder password from user-facing documentation/config comments when safe, but do not pretend the public hash is secret.

### Phase 6 — Deterministic quality tooling

Add or improve dependency-free validation where it creates durable value. The repository should be able to check:

- German/English product-page parity.
- No orphan locale files.
- No placeholder deployment values in a release build.
- No Docusaurus tutorial/sample content after cleanup.
- No unresolved placeholder pages except explicitly approved templates/plans.
- Sidebar Doc IDs resolve.
- Internal links build successfully in both locales.
- TypeScript passes.
- Production build passes.

Prefer a small repository script and npm command over manual-only checks. Do not add a large testing framework solely for simple file validation.

### Phase 7 — Final verification

Run every applicable command, including at minimum:

```text
npm run typecheck
npm run build
```

Also run any new content-validation command. If feasible, serve the production build and smoke-test:

- `/`
- A representative German documentation route.
- `/en/`
- The equivalent English documentation route.
- Navigation, locale switcher, theme switcher, password gate behavior, and copy-page button.

Check for browser console errors, hydration errors, broken images, inaccessible controls, overflow, unreadable contrast, and mobile layout failures when browser tooling is available.

## Quality bar for content

Every completed page must:

- Have a clear purpose and audience.
- Be based on existing repository evidence.
- Distinguish fact, research evidence, proposal, target, assumption, and open question.
- Avoid repeated generic marketing prose.
- Link to canonical supporting pages.
- Use accessible headings, tables, lists, links, and MDX.
- Match the Atomic DSB terminology and role model.
- Have an English counterpart with equivalent meaning.
- Contain no fabricated results or implementation claims.

## Completion behavior

Continue autonomously through all unblocked phases. When a genuine product decision blocks one item, record it precisely in Open Questions and continue with unrelated safe work.

Stop and request user input only for decisions that cannot be inferred safely, especially:

- Public vs genuinely private documentation.
- Final hosting target and production URL/base path.
- Final GitHub owner/repository coordinates.
- Whether the separate product repository is authoritative for technical architecture.
- Whether any placeholder meeting/interview record represents unpublished real evidence.

Do not use these blockers as a reason to stop other work.

## Definition of done

The repository is complete for the current documentation milestone when:

- Docusaurus starter tutorials/blog/sample assets are removed or intentionally retained with documented purpose.
- No sample deployment identity remains in releasable configuration.
- Every sidebar page contains meaningful German content or is an explicitly justified template/plan.
- German and English product pages have one-to-one parity.
- Requirements are traceable to research, personas, strategy, and prioritization.
- Design-system docs reflect actual tokens/components and do not overclaim automation.
- Decisions, risks, assumptions, open questions, and scope boundaries are explicit.
- Confidentiality limitations are impossible to misunderstand.
- Content validation, typecheck, and production build pass.
- Any unresolved user decisions are listed clearly without fabricated defaults.
- Temporary artifacts are removed.

## Final report format

At completion, report:

1. What was changed, grouped by phase.
2. Files removed and why they were safe to remove.
3. Pages completed and their evidence sources.
4. German/English parity counts.
5. Exact validation commands and exit results.
6. Remaining blockers requiring human decisions.
7. Known limitations and explicitly deferred work.

Do not claim success for checks that were not executed.
