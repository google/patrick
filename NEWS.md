# patrick (0.3.0)

*  Patrick can build test names as {glue}-formatted strings, e.g.

    ```r
    with_parameters_test_that(
      "col2hex works for color {color_name}",
      {
        expect_equal(col2hex(color_name), color_hex)
      },
      color_name = c("red", "blue", "black"),
      color_hex = c("#FF0000", "#0000FF", "#000000")
    )
    ```

    This also works for supplying such a formatted string as `.test_name`.

    To disable this behavior, use `.interpret_glue = FALSE`.

    Thanks @chiricom!

# patrick 0.2.0

## New features

*  Patrick will try to generate names automatically if not provided. This
   also works when cases are provided as a data frame.

# patrick 0.1.0

Breaking changes:

*  Setting test names should now happen with `.test_name`, instead of the
   implicit `test_name` variable from before. This is now an explicit
   argument for the function `with_parameters_test_that()`, and the leading dot
   should help distinguish this from values passed as cases.

# patrick 0.0.4

Update `patrick` for testthat 3e.

*  Catch warnings for code not being braced. We still produce the right code.
*  Make sure patrick uses the right line numbers.

# patrick 0.0.3

*   Add more examples and tests for how patrick works with data frames.
*   Update `with_parameters_test_that()` to use
    [data, dots, details](https://design.tidyverse.org/dots-after-required.html#whats-the-pattern)
*   Modernize package files: DESCRIPTION and `R/patrick-package.R`.

# patrick 0.0.2

*   This is a minor update. Tests are compatible with the next version of
    `testthat`.

# patrick 0.0.1

Welcome to `patrick`, a package for parameterizing tests within testthat. Check
out the README.md file to learn more about this package.
