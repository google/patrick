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
    if (test_outcome == "success") {
      testthat::expect_success(testthat::expect_true(case))
    } else {
      failure_message <- "`case` (isn't true|is not TRUE|to be TRUE)"
      testthat::expect_failure(testthat::expect_true(case), failure_message)
    }
  },
  test_outcome = c("success", "fail", "null"),
  case = list(TRUE, FALSE, NULL),
  .test_name = c("success", "fail", "null")
) |>
  expect_warning("test_these")
