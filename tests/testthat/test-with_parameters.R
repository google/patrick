context("Parameterized tests")

with_parameters_test_that("Running tests:", {
    if (test_name == "success") {
      testthat::expect_success(testthat::expect_true(case))
    } else {
      testthat::expect_failure(testthat::expect_true(case), "`case` isn't true")
    }
  },
  test_name = c("success", "fail", "null"),
  case = list(TRUE, FALSE, NULL),
)

with_parameters_test_that("Names are added", {
    testthat::expect_true(test_name == "")
  },
  case = TRUE
)

with_parameters_test_that("Cases are correctly evaluated:", {
    testthat::expect_length(vec, len)
  },
  cases(
    one = list(vec = 1, len = 1),
    ten = list(vec = 1:10, len = 10)
  )
)
