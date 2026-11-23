# Plan

Decision: the R side goes with an **R6 class** on top of the shared engine.

## Tracks

Three people, three tracks. If one person cannot take theirs, Nour takes it.

| Track | Scope (FSDA folder, .m files) | Owner |
|---|---|---|
| Core | class, engine fixes, tests, README, reviews | Nour |
| A | `regression` (73) | Simran |
| B | `multivariate` (46) | Ahmad |
| C | `graphics` (40), then `clustering` (36) | Nour |

Other folders (`utilities_stat`, `utilities`, `combinatorial`) are decided later.

## Phases

1. **Clean base**: fix `nameX` (list of strings is converted as numbers in `engine.py`), tests for `call()`, setup README, tab completion in VS Code, `.gitignore` for `__pycache__`.
2. **Function template and inventory**: one method + roxygen help + live check + demo line per function. Priority list per track.
3. **Coverage**: each owner works on their own branch and opens a PR; Nour reviews.
4. **Expansion**: try code generation for methods and docs on two functions; `R CMD check`; contributor guide with good first issues.

## Rules

- One branch per person and track, e.g. `simran/regression`.
- One PR per small group of functions, so reviews stay short.
- Tests and examples must not fail when MATLAB is not installed (CRAN in mind).
