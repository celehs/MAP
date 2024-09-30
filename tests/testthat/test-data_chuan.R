test_data_chuan <- function() {
  library(MAP)
  library(magrittr)

  dirpath = system.file('data', package = 'MAP')
  df_test = get(load(file.path(dirpath, 'data_to_Thomas.Rdata')))

  m_data = Matrix(data = cbind(ICD = df_test$`PheCode:714.1`, NLP = 1), sparse = TRUE)
  m_note = Matrix(df_test$utl, ncol = 1, sparse = TRUE)

  res_full = MAP(m_data, m_note)
  clusters = round(res_full$scores[, 1])

  df_perf = df_test %$% cbind.data.frame(clusters, RA_GoldStandard) %>% na.omit
  df_perf$RA_GoldStandard %<>% { ifelse(. == 'Y', 1, 0) }
  roc_obj = df_perf %$% pROC::roc(clusters, RA_GoldStandard)

  expect_equal(round(roc_obj$auc, 3), 0.897)

  n_half = nrow(m_data) %/% 2

  set.seed(1)
  res_half = MAP(m_data, m_note, subset_sample = TRUE, subset_sample_size = n_half)
  roc_obj = pROC::roc(clusters, round(res_half$scores[, 1]))

  expect_equal(round(roc_obj$auc, 3), 0.992)

  n_fifth = nrow(m_data) %/% 5

  set.seed(1)
  res_fifth = MAP(m_data, m_note, subset_sample = TRUE, subset_sample_size = n_fifth)
  roc_obj = pROC::roc(clusters, round(res_fifth$scores[, 1]))

  expect_equal(round(roc_obj$auc, 3), 0.972)
}
#test_that('data_chuan', test_data_chuan())
