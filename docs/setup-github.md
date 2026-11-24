# One-time GitHub setup (repo owner)

1. **Settings → General:** Wiki off, Discussions off · Pull Requests: allow **merge commits only** (untick squash and rebase) · tick *Automatically delete head branches*.
2. **Settings → Collaborators:** invite the 4 members with **Write**.
3. **Settings → Rules → Rulesets → New branch ruleset** `protect-main`, target = default branch, **no bypass list**:
   - Require a pull request before merging — **required approvals = 0** (self-merge allowed)
   - Require status checks to pass: `layout`, `lint`, `sim` (add after CI has run once so the names appear)
   - Block force pushes · Restrict deletions
4. **Settings → Code security:** secret scanning + push protection on.
5. Run `bash scripts/github/setup_github.sh` (gh CLI) for labels, milestones and issues; create a Projects board (Backlog → Ready → In progress → In review → Done).
6. From P2: in `.github/workflows/ci.yml` set `LINT_STRICT: "true"`. From P3: set the `synth` job to `continue-on-error: false` and add `synth` as a required check.
