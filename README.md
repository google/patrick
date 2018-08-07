# Introducing patrick

This package is an extension to `testthat` that enables parameterized testing in
R.

## Installing

`patrick` is currently only available on GitHub. Install it using `devtools`.

```
devtools::install_github("google/patrick")
```

To use `patrick` as a testing tool within your package, add it to your list of
`Suggests` and `Remotes` within your package's `DESCRIPTION`.

```
Suggests:
    patrick
Remotes:
    google/patrick
```

## Use

Many packages within R employ the following pattern when writing tests:

```
test_that("Data is a successfully converted: numeric", {
  input <- convert(numeric_data)
  expect_is(input, "numeric")
})

test_that("Data is a successfully converted: character", {
  input <- convert(character_data)
  expect_is(input, "character")
})
```

While explicit, recycling a test pattern like this is prone to user error and
other issues, as it is a violation of the classic DNRY rule (do not repeat
yourself). `patrick` eliminates this problem by creating test parameters.

```
with_parameters_test_that("Data is successfully converted:", {
    input <- convert(test_data)
    expect_is(input, type)
  },
  test_name = c("numeric", "character"),
  test_data = list(numeric_data, character_data),
  type = c("numeric", "character")
)
```

Parameterized tests behave exactly the same as standard `testthat` tests. Per
usual, you call all of your tests with `devtools::test`, and they'll also run
during package checks. Each executes independently and then your test report will
produce a single report. A complete name for each test will be formed using the
initial test description and the strings in the `test_name` parameter.

Small sets of cases can be reasonably passed a parameters to
`with_parameters_test_that`. This becomes less readable when the number of cases
increases. To help mitigate this issue, `patrick` provides a case generator
helper function.

```
with_parameters_test_that("Data is successfully converted:", {
    input <- convert(test_data)
    expect_is(input, type)
  },
  cases(
    numeric = list(test_data = numeric_data, type = "numeric"),
    character = list(test_data = character_data, type = "character")
  )
)
```

## Inspiration

This package is inspired by parameterized testing packages in other languages,
notably the [`parameterized`](https://github.com/wolever/parameterized) library
in Python.

## Contributing

Please read the [`CONTRIBUTING.md`](CONTRIBUTING.md) for details on how to
contribute to this project.

## Disclaimer

This is not an officially supported Google product.
