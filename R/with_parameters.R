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

#' Legacy API for parameterized tests
#'
#' We are moving away from this function name in favor of [test_these()].
#'
#' @inheritParams test_these
#' @export
with_parameters_test_that <- function(desc_stub,
                                      code,
                                      ...,
                                      .cases = NULL,
                                      .test_name = NULL,
                                      .interpret_glue = TRUE) {
  .Deprecated("test_these")
  test_these(desc_stub, code,
    .cases = .cases,
    .test_name = .test_name,
    .interpret_glue = .interpret_glue, 
    ...
  )
}
