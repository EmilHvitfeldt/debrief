# Export profiling results as JSON

Exports profiling analysis results in JSON format for consumption by AI
agents, automated tools, or external applications.

## Usage

``` r
pv_to_json(
  x,
  file = NULL,
  pretty = TRUE,
  include = c("summary", "self_time", "total_time", "hot_lines", "memory", "gc_pressure",
    "suggestions", "recursive"),
  system_info = FALSE
)
```

## Arguments

- x:

  A profvis object.

- file:

  Optional file path to write JSON to. If `NULL`, returns the JSON
  string.

- pretty:

  If `TRUE`, formats JSON with indentation for readability.

- include:

  Character vector specifying which analyses to include. Options:
  "summary", "self_time", "total_time", "hot_lines", "memory",
  "callers", "gc_pressure", "suggestions", "recursive". Default includes
  all.

- system_info:

  If `TRUE`, includes R version and platform info in metadata. Useful
  for reproducibility.

## Value

If `file` is `NULL`, returns a JSON string. Otherwise writes to file and
returns the file path invisibly.

## Examples

``` r
p <- pv_example()
json <- pv_to_json(p)
cat(json)
#> {
#>   "metadata": {
#>     "total_time_ms": 50,
#>     "total_samples": 5,
#>     "interval_ms": 10,
#>     "has_source_refs": true,
#>     "exported_at": "2026-02-28T00:14:02+0000"
#>   },
#>   "summary": {
#>     "total_time_ms": 50,
#>     "unique_functions": 4,
#>     "max_depth": 3
#>   },
#>   "self_time": [
#>     {
#>       "label": "deep",
#>       "samples": 2,
#>       "time_ms": 20,
#>       "pct": 40
#>     },
#>     {
#>       "label": "helper",
#>       "samples": 1,
#>       "time_ms": 10,
#>       "pct": 20
#>     },
#>     {
#>       "label": "inner",
#>       "samples": 1,
#>       "time_ms": 10,
#>       "pct": 20
#>     },
#>     {
#>       "label": "outer",
#>       "samples": 1,
#>       "time_ms": 10,
#>       "pct": 20
#>     }
#>   ],
#>   "total_time": [
#>     {
#>       "label": "outer",
#>       "samples": 5,
#>       "time_ms": 50,
#>       "pct": 100
#>     },
#>     {
#>       "label": "inner",
#>       "samples": 3,
#>       "time_ms": 30,
#>       "pct": 60
#>     },
#>     {
#>       "label": "deep",
#>       "samples": 2,
#>       "time_ms": 20,
#>       "pct": 40
#>     },
#>     {
#>       "label": "helper",
#>       "samples": 1,
#>       "time_ms": 10,
#>       "pct": 20
#>     }
#>   ],
#>   "hot_lines": [
#>     {
#>       "location": "R/utils.R:5",
#>       "samples": 2,
#>       "label": "deep",
#>       "filename": "R/utils.R",
#>       "linenum": 5,
#>       "time_ms": 20,
#>       "pct": 40
#>     },
#>     {
#>       "location": "R/helper.R:20",
#>       "samples": 1,
#>       "label": "helper",
#>       "filename": "R/helper.R",
#>       "linenum": 20,
#>       "time_ms": 10,
#>       "pct": 20
#>     },
#>     {
#>       "location": "R/main.R:10",
#>       "samples": 1,
#>       "label": "outer",
#>       "filename": "R/main.R",
#>       "linenum": 10,
#>       "time_ms": 10,
#>       "pct": 20
#>     },
#>     {
#>       "location": "R/main.R:15",
#>       "samples": 1,
#>       "label": "inner",
#>       "filename": "R/main.R",
#>       "linenum": 15,
#>       "time_ms": 10,
#>       "pct": 20
#>     }
#>   ],
#>   "memory": {
#>     "by_function": [
#>       {
#>         "label": "inner",
#>         "mem_mb": 150
#>       },
#>       {
#>         "label": "deep",
#>         "mem_mb": 100
#>       },
#>       {
#>         "label": "helper",
#>         "mem_mb": 50
#>       }
#>     ],
#>     "by_line": [
#>       {
#>         "location": "R/main.R:15",
#>         "mem_mb": 150,
#>         "label": "inner",
#>         "filename": "R/main.R",
#>         "linenum": 15
#>       },
#>       {
#>         "location": "R/utils.R:5",
#>         "mem_mb": 100,
#>         "label": "deep",
#>         "filename": "R/utils.R",
#>         "linenum": 5
#>       },
#>       {
#>         "location": "R/helper.R:20",
#>         "mem_mb": 50,
#>         "label": "helper",
#>         "filename": "R/helper.R",
#>         "linenum": 20
#>       }
#>     ]
#>   },
#>   "gc_pressure": [],
#>   "suggestions": [
#>     {
#>       "priority": 1,
#>       "category": "hot line",
#>       "suggestion": "Line 'deep' at R/utils.R:5 consumes 40.0% of time. Focus optimization efforts here first.",
#>       "location": "R/utils.R:5",
#>       "potential_impact": "20 ms (40.0%)"
#>     },
#>     {
#>       "priority": 1,
#>       "category": "hot line",
#>       "suggestion": "Line 'helper' at R/helper.R:20 consumes 20.0% of time. Focus optimization efforts here first.",
#>       "location": "R/helper.R:20",
#>       "potential_impact": "10 ms (20.0%)"
#>     },
#>     {
#>       "priority": 1,
#>       "category": "hot line",
#>       "suggestion": "Line 'outer' at R/main.R:10 consumes 20.0% of time. Focus optimization efforts here first.",
#>       "location": "R/main.R:10",
#>       "potential_impact": "10 ms (20.0%)"
#>     },
#>     {
#>       "priority": 2,
#>       "category": "hot function",
#>       "suggestion": "Function 'deep' has highest self-time (40.0%). Profile this function in isolation to find micro-optimization opportunities.",
#>       "location": "deep",
#>       "potential_impact": "20 ms (40.0%)"
#>     }
#>   ],
#>   "recursive": []
#> }

# Include only specific analyses
json <- pv_to_json(p, include = c("self_time", "hot_lines"))

# Include system info for reproducibility
json <- pv_to_json(p, system_info = TRUE)
```
