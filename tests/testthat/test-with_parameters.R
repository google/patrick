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

with_parameters_test_that(
  "Running tests:",
  {
    if (test_name == "success") {
      testthat::expect_success(testthat::expect_true(case))
    } else {
      failure_message <- "`case` (isn't true|is not TRUE)"
      testthat::expect_failure(testthat::expect_true(case), failure_message)
    }
  },
  test_name = c("success", "fail", "null"),
  case = list(TRUE, FALSE, NULL),
)

with_parameters_test_that(
  "Names are added",
  {
    testthat::expect_true(test_name == "")
  },
  case = TRUE
)

with_parameters_test_that(
  "Cases are correctly evaluated:",
  {
    testthat::expect_length(vec, len)
  },
  cases(
    one = list(vec = 1, len = 1),
    ten = list(vec = 1:10, len = 10)
  )
)

with_parameters_test_that(
  "Data frames can be passed to cases:",
  {
    result <- rlang::as_function(FUN)(input)
    testthat::expect_equal(result, out)
  },
  .cases = tibble::tribble(
    ~test_name, ~FUN, ~input, ~out,
    "times", ~ .x * 2, 2, 4,
    "plus", ~ .x + 3, 3, 6
  )
)

with_parameters_test_that("Patrick doesn't throw inappropriate warnings:", {
    testthat::expect_warning(fun(), regexp = message)
  },
  cases(
    shouldnt_warn = list(fun = function() 1 + 1, message = NA),
    should_warn = list(
      fun = function () warning("still warn!"),
      message = "still warn"
    )
  )
)

test_that("Patrick catches the right class of warning", {
  # TODO: Find a replacement for testthat's deprecated mock functions.
  testthat::local_mock(
     test_that = function(...) {
       rlang::warn("New warning", class = "testthat_braces_warning")
     },
    .env = "testthat"
  )
  testthat::expect_warning(
    with_parameters_test_that(
      "No more warnings:",
      {
        testthat::expect_true(truth)
      },
      truth = TRUE
    ),
    regexp = NA
  )
})

# From testthat/tests/testthat/test-test-that.R
# Use for checking that line numbers are still correct
expectation_lines <- function(code) {
  srcref <- attr(substitute(code), "srcref")
  if (!is.list(srcref)) {
    stop("code doesn't have srcref", call. = FALSE)
  }

  results <- testthat::with_reporter("silent", code)$expectations()
  unlist(lapply(results, function(x) x$srcref[1])) - srcref[[1]][1]
}

test_that("patrick reports the correct line numbers", {
  lines <- expectation_lines({
                                                 # line 1
    with_parameters_test_that("simple", {        # line 2
      expect_true(truth)                         # line 3
    },                                           # line 4
    cases(
      true = list(truth = TRUE),
      false = list(truth = FALSE)
    ))
  })
  expect_equal(lines, c(3, 3))
})
