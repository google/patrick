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

#' Parameterized Unit Testing
#'
#' `patrick` (parameterized testing in R is kind of cool!) is a `testthat`
#' extension that lets you create reusable blocks of a test codes. Parameterized
#' tests are often easier to read and more reliable, since they follow the DNRY
#' (do not repeat yourself) rule. To do this, define tests with the function
#' [with_parameters_test_that()]. Multiple approaches are provided for passing
#' sets of cases.
#'
#' This package is inspired by parameterized testing packages in other
#' languages, notably the
#' [`parameterized`](https://github.com/wolever/parameterized) library in
#' Python.
#' @keywords internal
#' @inherit with_parameters_test_that examples
"_PACKAGE"
