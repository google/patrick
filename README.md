<!-- badges: start -->

[![R-CMD-check](https://github.com/google/patrick/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/google/patrick/actions/workflows/R-CMD-check.yaml)
[![CRAN](https://www.r-pkg.org/badges/version/patrick)](https://cran.r-project.org/package=patrick)
<!-- badges: end -->

# Introducing patrick

This package is an extension to `testthat` that enables parameterized unit
testing in R.

## Installing

The release version of `patrick` is available on CRAN. Install it in the usual
manner:

```
install.packages("patrick")
```

The development version of `patrick` is currently only available on GitHub.
Install it using `devtools`.

```
devtools::install_github("google/patrick")
```

To use `patrick` as a testing tool within your package, add it to your list of
`Suggests` within your package's `DESCRIPTION`.

```
Suggests:
    patrick
```

## Use

Many packages within R employ the following pattern when writing tests:

```
test_that("Data is a successfully converted: numeric", {
  input <- convert(numeric_data)
  expect_type(input, "double")
})

test_that("Data is a successfully converted: character", {
  input <- convert(character_data)
  expect_type(input, "character")
})
```

While explicit, recycling a test pattern like this is prone to user error and
other issues, as it is a violation of the classic DNRY rule (do not repeat
yourself). `patrick` eliminates this problem by creating test parameters.

```
test_these("Data is successfully converted:", {
    input <- convert(test_data)
    expect_type(input, type)
  },
  cases(
    double = list(test_data = numeric_data, type = "double"),
    character = list(test_data = character_data, type = "character")
  )
)
```

Parameterized tests behave exactly the same as standard `testthat` tests. Per
usual, you call all of your tests with `devtools::test()`, and they'll also run
during package checks. Each executes independently and then your test report
will produce a single report. Test names for each case are extracted from the
cases object.

Small sets of cases can be reasonably passed as parameters to
`test_these`, but note that this becomes less readable when the number of cases
increases. In this case, a complete name for each test will be formed using
the initial test description and the strings in the `.test_name` parameter.

```
test_these("Data is successfully converted:", {
    input <- convert(test_data)
    expect_type(input, type)
  },
  test_data = list(numeric_data, character_data),
  type = c("double", "character"),
  .test_name = type
)
```

More complicated testing cases can be constructed using data frames. This is
usually best handled within a helper function and in a `helper-<test>.R` file.

```
make_cases <- function() {
  tibble::tribble(
    ~ .test_name, ~ expr,      ~ numeric_value,
    "sin",       sin(pi / 4),     1 / sqrt(2),
    "cos",       cos(pi / 4),     1 / sqrt(2),
    "tan",       tan(pi / 4),               1
  )
}

test_these(
  "trigonometric functions match identities:",
  {
    testthat::expect_equal(expr, numeric_value)
  },
  .cases = make_cases()
)
```

If you don't provide test names when generating cases, `patrick` will generate
them automatically from the test data.

### On test failure

On test failure, you should get the same error reports as `testthat`, since
`patrick` is largely a `testthat` wrapper. Extending the example above:

```
make_cases <- function() {
  tibble::tribble(
    ~ .test_name, ~ expr,      ~ numeric_value,
    "sin",       sin(pi / 4),     1 / sqrt(2),
    "cos",       cos(pi / 4),     1 / sqrt(2),
    "tan",       tan(pi / 4),               1,
    "bad tan",   tan(pi / 4),               1.5,
  )
}

test_these(
  "trigonometric functions match identities:",
  {
    testthat::expect_equal(expr, numeric_value)
  },
  .cases = make_cases()
)
#> ── Failure: trigonometric functions match identities: bad tan ───────
#> `expr` (`actual`) not equal to `numeric_value` (`expected`).
#> 
#>   `actual`: 1.00
#> `expected`: 1.50
#> Backtrace:
#>     ▆
#>  1. ├─rlang::eval_tidy(code, args)
#>  2. └─testthat::expect_equal(expr, numeric_value)
```

Your test carries over the name that you provided to identify the failing case.
If you don't provide a name, this is generated from values in the data for
the test case. For example,

```
test_these(
  "This will fail:",
  {
    expect_false(case)
  },
  case = TRUE
)
#> ── Failure: This will fail: case=TRUE ──────────────────────────────
#> `case` is not FALSE
#> 
#> `actual`:   TRUE 
#> `expected`: FALSE
#> Backtrace:
#>     ▆
#>  1. ├─rlang::eval_tidy(code, args)
#>  2. └─testthat::expect_false(case)
```

Generally speaking, it's better to label your cases manually if you are passing
a lot of parameters.

## Inspiration

This package is inspired by parameterized testing packages in other languages,
notably the [`parameterized`](https://github.com/wolever/parameterized) library
in Python.

## Contributing

Please read the
[`CONTRIBUTING.md`](https://github.com/google/patrick/blob/master/CONTRIBUTING.md)
for details on how to contribute to this project.

## Disclaimer

This is not an officially supported Google product.
