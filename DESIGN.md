# debrief package design

## Primary goal

**Output that is easily parsed and actionable by AI agents.**

This is the top priority. Every design decision flows from this:

1.  **Parseable** - Consistent structure so AI can extract file paths,
    line numbers, function names, and metrics
2.  **Actionable** - Include enough context (source code, percentages,
    concrete numbers) for AI to suggest specific fixes
3.  **Concise** - No verbose prose; use structured lists, tables, and
    clear labels
4.  **Self-contained** - Each output should include all information
    needed to act without additional queries

## Do

- Always include `filename:linenum` when source location is available
- Show actual source code alongside hot spots so AI can suggest fixes
- Use consistent column names (`label`, `samples`, `time_ms`, `pct`,
  `filename`, `linenum`)
- Return data frames from `pv_X()` functions for programmatic access
- Include percentages and absolute numbers together
- Make error messages actionable - tell the user exactly what to do

## Don’t

- No ANSI colors or terminal escape codes
- No Unicode characters - use ASCII only for cross-platform
  compatibility
- No interactive prompts
- No vague language (“some functions”, “may be slow”) - be specific
- No prose paragraphs - use structured output
- Don’t omit context that would require a follow-up query

## Function naming

- All exported functions use the `pv_` prefix
- `pv_X()` returns data (data frame or list) for programmatic use
- `pv_print_X()` prints formatted text and returns invisibly
- Internal helpers have no prefix and no roxygen docs

## Common parameters

Filtering parameters help AI agents focus on significant results: -
`n` - limit number of results - `min_pct` - minimum percentage
threshold - `min_time_ms` - minimum time threshold

## Input validation

Every exported function that takes a profvis object must start with:

``` r
check_profvis(x)
check_empty_profile(x)
```

## Error handling

- Use `stop(..., call. = FALSE)` for errors
- Do not use cli or rlang for errors
- Error messages must be actionable - tell the user what to do to fix it

## Utilities

`R/utils.R` contains shared helpers for validation, data extraction, and
formatting. Read it before adding new functions.

## Adding new analysis functions

1.  Create `pv_X()` that returns a data frame with standard columns
2.  Create `pv_print_X()` that prints formatted output
3.  Both must call `check_profvis(x)` and `check_empty_profile(x)`
4.  Add filtering parameters (`n`, `min_pct`, `min_time_ms`) where
    appropriate
5.  Add to `_pkgdown.yml` in the appropriate category
6.  Add tests in `tests/testthat/test-{name}.R`
7.  **Verify output serves the primary goal** - is it parseable,
    actionable, concise, and self-contained?
