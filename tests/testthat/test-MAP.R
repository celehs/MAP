# devtools::load_all()
# library(MAP)

context('MAP')

set.seed(123)
n = 400
ICD = c(rpois(n / 4, 10), rpois(n / 4, 1), rep(0, n / 2))
NLP = c(rpois(n / 4, 10), rpois(n / 4, 1), rep(0, n / 2))
mat = Matrix(data = cbind(ICD, NLP), sparse = TRUE)
note = Matrix(rpois(n, 10) + 5, ncol = 1, sparse = TRUE)

res_full = MAP(mat = mat, note = note)
clusters = round(res_full$scores[, 1])

test_MAP <- function() {

  expect_equal(dim(head(res_full$scores)), c(6, 1))

  expect_equal(round(res_full$cut.MAP, 3), 0.282)

  expect_equal(sum(clusters), 99)

}
test_that('MAP', test_MAP())

test_fitproj <- function() {

  # take 50%
  # why is it 82 and not 200 ?
  set.seed(1)
  res_sample = MAP(mat = mat, note = note, subset_sample = TRUE,
            subset_sample_size = 82)

  expect_equal(round(res_sample$cut.MAP, 3), 0.462)

  clusters_sample = round(res_sample$scores[, 1])
  expect_equal(sum(clusters_sample), 106)

  roc_obj = pROC::roc(clusters, clusters_sample)
  expect_equal(round(roc_obj$auc, 3), 0.814)
}
test_that('fitproj', test_fitproj())


