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
#' One parameter is noteworthy. If the user passes a character vector as
#' `test_name`, each instance is combined with `desc_stub` to create the
#' completed test name. Similarly, the named argument from `cases()` is combined
#' with `desc_stub` to create the parameterized test names.
#'
#' @param desc_stub A string scalar. Used in creating the names of the
#'  parameterized tests.
#' @param code Test code containing expectations.
#' @param .cases A data frame where each row contains test parameters.
#' @param ... Named arguments of test parameters.
#' @examples
#' with_parameters_test_that("trigonometric functions match identities",
#'   {
#'     testthat::expect_equal(expr, numeric_value)
#'   },
#'   expr = c(sin(pi / 4), cos(pi / 4), tan(pi / 4)),
#'   numeric_value = c(1 / sqrt(2), 1 / sqrt(2), 1)
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
#' @export
with_parameters_test_that <- function(desc_stub, code, .cases = NULL, ...) {
  if (!is.null(.cases)) {
    all_pars <- .cases
  } else {
    pars <- tibble::tibble(...)
    all_pars <- purrr::possibly(tibble::add_column, pars)(pars, test_name = "")
  }
  captured <- rlang::enquo(code)
  purrr::pmap(all_pars, build_and_run_test, desc = desc_stub, code = captured)
  invisible(TRUE)
}

build_and_run_test <- function(..., test_name, desc, code, env) {
  completed_desc <- paste(desc, test_name)
  args <- list(..., test_name = test_name)
  testthat::test_that(completed_desc, rlang::eval_tidy(code, args))
}

#' @rdname with_parameters_test_that
#' @export
cases <- function(...) {
  all_cases <- list(...)
  nested <- purrr::modify_depth(all_cases, 2, list)
  dplyr::bind_rows(nested, .id = "test_name")
}
