test_data_chuan <- function() {
  devtools::load_all()
  library(magrittr)

  dirpath = system.file('data', package = 'MAP')
  df_test = get(load(file.path(dirpath, 'data_to_Thomas.Rdata')))

  df_test$RA_GoldStandard %<>% { ifelse(. == 'Y', 1, 0) }

  m_data = Matrix(data = cbind(ICD = df_test$`PheCode:714.1`, NLP = 1),
                  sparse = TRUE)
  m_note = Matrix(df_test$utl, ncol = 1, sparse = TRUE)

  set.seed(1)
  res_full = MAP(m_data, m_note)

  # users can either use cut.MAP to binarize or determine a threshold
  # themselves with AUC

  df_perf_full = df_test %$% cbind.data.frame(scores = res_full$scores[, 1],
                                         RA_GoldStandard) %>% na.omit

  roc_obj = df_perf_full %$% pROC::roc(RA_GoldStandard, scores)

  expect_equal(round(roc_obj$auc, 3), 0.93)

  n_half = nrow(m_data) %/% 2

  set.seed(1)
  res_half = MAP(m_data, m_note, subset_sample = TRUE,
                 subset_sample_size = n_half)
  df_perf = df_test %$% cbind.data.frame(scores = res_half$scores[, 1],
                                         RA_GoldStandard) %>% na.omit

  roc_obj = df_perf %$% pROC::roc(RA_GoldStandard, scores)

  expect_equal(round(roc_obj$auc, 3), 0.929)

  roc_obj = pROC::roc(res_full$scores[, 1] < res_full$cut.MAP,
                      as.numeric(res_half$scores[, 1] < res_half$cut.MAP))

  expect_equal(round(roc_obj$auc, 3), 0.993)

  n_fifth = nrow(m_data) %/% 5

  set.seed(1)
  res_fifth = MAP(m_data, m_note, subset_sample = TRUE, subset_sample_size = n_fifth)
  df_perf = df_test %$% cbind.data.frame(scores = res_fifth$scores[, 1],
                                         RA_GoldStandard) %>% na.omit

  roc_obj = df_perf %$% pROC::roc(RA_GoldStandard, scores)

  expect_equal(round(roc_obj$auc, 3), 0.93)

  roc_obj = pROC::roc(res_full$scores[, 1] < res_full$cut.MAP,
                      as.numeric(res_fifth$scores[, 1] < res_fifth$cut.MAP))

  expect_equal(round(roc_obj$auc, 3), 0.993)

  set.seed(1)
  auc = 0
  for (i in 1:5) {

    res_half = MAP(m_data, m_note, subset_sample = TRUE,
                   subset_sample_size = n_half)

    df_perf = df_test %$% cbind.data.frame(scores = res_half$scores[, 1],
                                           RA_GoldStandard) %>% na.omit
 
    roc_obj = df_perf %$% pROC::roc(RA_GoldStandard, scores)
    auc = auc + roc_obj$auc
  }

  expect_equal(round(auc / 5, 3), 0.929)

  set.seed(1)
  auc = 0
  for (i in 1:5) {

    res_fifth = MAP(m_data, m_note, subset_sample = TRUE,
                   subset_sample_size = n_fifth)

    df_perf = df_test %$% cbind.data.frame(scores = res_fifth$scores[, 1],
                                           RA_GoldStandard) %>% na.omit
 
    roc_obj = df_perf %$% pROC::roc(RA_GoldStandard, scores)
    auc = auc + roc_obj$auc
  }

  expect_equal(round(auc / 5, 3), 0.929)

  set.seed(1)
  auc = 0
  for (i in 1:5) {

    res_tenth = MAP(m_data, m_note, subset_sample = TRUE,
                   subset_sample_size = n_fifth %/% 2)

    df_perf = df_test %$% cbind.data.frame(scores = res_tenth$scores[, 1],
                                           RA_GoldStandard) %>% na.omit
 
    roc_obj = df_perf %$% pROC::roc(RA_GoldStandard, scores)
    auc = auc + roc_obj$auc
  }

  expect_equal(round(auc / 5, 3), 0.928)

  set.seed(1)
  auc = 0
  for (i in 1:5) {

    res_tenth = MAP(m_data, m_note, subset_sample = TRUE,
                   subset_sample_size = 16)

    df_perf = df_test %$% cbind.data.frame(scores = res_tenth$scores[, 1],
                                           RA_GoldStandard) %>% na.omit
 
    roc_obj = df_perf %$% pROC::roc(RA_GoldStandard, scores)
    auc = auc + roc_obj$auc
  }

  expect_equal(round(auc / 5, 3), 0.914)
}
#test_that('data_chuan', test_data_chuan())
