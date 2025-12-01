# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Execute a test with parameters.
#'
#' This function is an extension of [testthat::test_that()] that lets you pass
#' a series of testing parameters. These values are substituted into your
#' regular testing code block, making it reusable and reducing duplication.
#'
#' You have a couple of options for passing parameters to you test. You can
#' use named vectors/ lists. The function will assert that you have correct
#' lengths before proceeding to test execution. Alternatively you can used
#' a `data.frame` or list in combination with the splice unquote operator
#' \code{\link[rlang]{!!!}}. Last, you can use the constructor `cases()`, which
#' is similar to building a `data.frame` rowwise. If you manually build the
#' data frame, pass it in the `.cases` argument.
#'
#' ## Naming test cases
#'
#' If the user passes a character vector as `.test_name`, each instance is
#' combined with `desc_stub` to create the completed test name. Similarly, the
#' named argument from `cases()` is combined with `desc_stub` to create the
#' parameterized test names. When names aren't provided, they will be
#' automatically generated using the test data.
#'
#' Names follow the pattern of "name=value, name=value" for all elements in a
#' test case.
#'
#' @param desc_stub A string scalar. Used in creating the names of the
#'   parameterized tests.
#' @param code Test code containing expectations.
#' @param ... Named arguments of test parameters. All vectors should have the
#'   same length.
#' @param .cases A data frame where each row contains test parameters.
#' @param .test_name An alternative way for providing test names. If provided,
#'   the name will be appended to the stub description in `desc_stub`. If not
#'   provided, test names will be automatically generated.
#' @param .interpret_glue Logical, default `TRUE`. If `FALSE`, and glue-like
#'   markup in `desc_stub` is ignored, otherwise [glue::glue_data()] is
#'   attempted to produce a more complete test description.
#' @examples
#' with_parameters_test_that("trigonometric functions match identities:",
#'   {
#'     testthat::expect_equal(expr, numeric_value)
#'   },
#'   expr = c(sin(pi / 4), cos(pi / 4), tan(pi / 4)),
#'   numeric_value = c(1 / sqrt(2), 1 / sqrt(2), 1),
#'   .test_name = c("sin", "cos", "tan")
#' )
#'
#' # Run the same test with the cases() constructor
#' with_parameters_test_that(
#'   "trigonometric functions match identities",
#'   {
#'     testthat::expect_equal(expr, numeric_value)
#'   },
#'   cases(
#'     sin = list(expr = sin(pi / 4), numeric_value = 1 / sqrt(2)),
#'     cos = list(expr = cos(pi / 4), numeric_value = 1 / sqrt(2)),
#'     tan = list(expr = tan(pi / 4), numeric_value = 1)
#'   )
#' )
#'
#' # If names aren't provided, they are automatically generated.
#' with_parameters_test_that(
#'   "trigonometric functions match identities",
#'   {
#'     testthat::expect_equal(expr, numeric_value)
#'   },
#'   cases(
#'     list(expr = sin(pi / 4), numeric_value = 1 / sqrt(2)),
#'     list(expr = cos(pi / 4), numeric_value = 1 / sqrt(2)),
#'     list(expr = tan(pi / 4), numeric_value = 1)
#'   )
#' )
#' # The first test case is named "expr=0.7071068, numeric_value="0.7071068"
#' # and so on.
#'
#' # Or, pass a data frame of cases, perhaps using a helper function
#' make_cases <- function() {
#'   tibble::tribble(
#'     ~.test_name, ~expr, ~numeric_value,
#'     "sin", sin(pi / 4), 1 / sqrt(2),
#'     "cos", cos(pi / 4), 1 / sqrt(2),
#'     "tan", tan(pi / 4), 1
#'   )
#' }
#'
#' with_parameters_test_that(
#'   "trigonometric functions match identities",
#'   {
#'     testthat::expect_equal(expr, numeric_value)
#'   },
#'   .cases = make_cases()
#' )
#' @importFrom dplyr .data
#' @export
with_parameters_test_that <- function(desc_stub,
                                      code,
                                      ...,
                                      .cases = NULL,
                                      .test_name = NULL,
                                      .interpret_glue = TRUE) {
  stopifnot(
    is.logical(.interpret_glue),
    length(.interpret_glue) == 1L,
    !is.na(.interpret_glue)
  )
  if (is.null(.cases)) {
    pars <- tibble(...)
    possibly_add_column <- possibly(add_column, otherwise = pars)
    all_pars <- possibly_add_column(pars, .test_name = .test_name)
  } else {
    all_pars <- .cases
  }
  # TODO(#33): deprecate & remove this branch
  if ("test_name" %in% names(all_pars)) {
    msg <- paste(
      'The argument and cases column "test_name" is deprecated. Please use the',
      "new `.test_name` argument instead. See `?with_parameters_test_that`",
      "for more information"
    )
    warn(msg, class = "patrick_test_name_deprecation")
    # It would be nicer to do this with rename(), but that function doesn't
    # support overwriting existing columns.
    all_pars <- mutate(
      all_pars,
      .test_name = .data$test_name,
      test_name = NULL
    )
  }
  if (!".test_name" %in% names(all_pars)) {
    all_pars$.test_name <- build_test_names(all_pars)
  }
  captured <- enquo(code)
  pmap(
    all_pars,
    build_and_run_test,
    desc = desc_stub,
    code = captured,
    .interpret_glue = .interpret_glue
  )
  invisible(TRUE)
}

#' Generate test names from cases, if none are provided.
#'
#' @param all_cases A tibble containing test cases.
#' @return A character vector, whose length matches the number of rows in
#'   `all_cases`.
#' @noRd
build_test_names <- function(all_cases) {
  case_names <- names(all_cases)
  pmap_chr(all_cases, build_label, case_names = case_names)
}

build_label <- function(..., case_names) {
  case_row <- format(list(...))
  toString(sprintf("%s=%s", case_names, case_row))
}

build_description <- function(args, desc, .test_name, .interpret_glue) {
  if (.interpret_glue) {
    completed_desc <- tryCatch(glue_data(args, desc), error = identity)
    if (inherits(completed_desc, "error")) {
      abort(sprintf(
        paste(
          "Attempt to interpret test stub '%s' with glue failed with error:",
          "%s", "",
          "Set .interpret_glue=FALSE if this test name does not use glue.",
          sep = "\n"
        ),
        # indent for clarity (the purrr error has similar mark-up)
        desc, gsub("(^|\n)", "\\1  ", conditionMessage(completed_desc))
      ))
    }
  } else {
    completed_desc <- desc
  }
  desc_n <- length(completed_desc)
  if (desc_n != 1L || completed_desc == desc) {
    completed_desc <- paste(desc, .test_name)
    if (desc_n != 1L) {
      warn(
        paste("glue_data() on desc= produced output of length", desc_n)
      )
    } else if (.interpret_glue) {
      completed_desc <- glue_data(args, completed_desc)
    }
  }
  completed_desc
}

build_and_run_test <- function(
  ..., .test_name, desc, code, env, .interpret_glue
) {
  test_args <- list(..., .test_name = .test_name)
  completed_desc <-
    build_description(test_args, desc, .test_name, .interpret_glue)

  withCallingHandlers(
    test_that(completed_desc, eval_tidy(code, test_args)),
    testthat_braces_warning = cnd_muffle
  )
}

#' @rdname with_parameters_test_that
#' @export
cases <- function(...) {
  all_cases <- list(...)
  nested <- modify_depth(all_cases, 2L, list)
  bind_rows(
    nested,
    .id = if (!is.null(names(nested))) ".test_name"
  )
}
