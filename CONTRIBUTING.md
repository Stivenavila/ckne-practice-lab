# Branching and contribution convention

This repo follows **GitHub Flow**: a simple model built for fast iteration
without release ceremony.

## Rules

1. `main` should always be in a deployable/working state. Don't push directly to
   it except for trivial documentation fixes.
2. Every new change goes into a short-lived branch, named after the type of
   change:
   - `feature/<short-name>` — new functionality
   - `fix/<short-name>` — bug fix
   - `chore/<short-name>` — maintenance, dependencies, configuration
   - `docs/<short-name>` — documentation only
3. Open a Pull Request into `main` once the branch is ready. Describe what
   changes and why (the diff already shows the what).
4. Merge with **squash merge** to keep `main`'s history clean (one commit per
   PR, no intermediate "wip" or "fix typo" commits).
5. Delete the branch after merging (`gh pr merge --delete-branch`).

## Example flow

```bash
git checkout main
git pull
git checkout -b feature/task-name

# ... work and commit ...

git push -u origin feature/task-name
gh pr create --fill

# after review and merge:
git checkout main
git pull
git branch -d feature/task-name
```

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/), in English:

```
<type>: <short summary in the imperative>

<optional body: why the change is needed>
```

| Type | Use it for |
|---|---|
| `feat` | a new scenario, simulator feature or console capability |
| `fix` | a bug fix |
| `docs` | documentation only |
| `refactor` | code changes that don't change behaviour |
| `ci` | GitHub Actions and automation |
| `chore` | maintenance, dependencies, configuration |

Focus the summary and body on the **why** — the diff already shows the what.
Because PRs are squash-merged, the **PR title** becomes the commit message on
`main`, so give it the same format.

## Long-lived or shared branches

If a branch is going to live for more than a few days or more than one person
is going to touch it, flag it early in the PR (draft PR) instead of quietly
piling up commits — it avoids large conflicts at the end.
