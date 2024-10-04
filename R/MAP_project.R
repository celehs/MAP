# Fit MAP on sample_size patients, project remaining
fitproj_flexmix = function(tmpfm, note, family, tmpfm2, dat.tmp, sample_size) {

  m_data = dat.tmp
  m_note = note

  rownames(m_data) = seq_len(nrow(m_data))
  fit_sample = sample(as.numeric(rownames(m_data)), sample_size)

  m_fit = m_data[fit_sample, ]
  m_fit_note = m_note[fit_sample, ]

  m_project = m_data[-fit_sample, ]
  m_project_note = m_note[-fit_sample, ]

  fit_obj = fit_flexmix(tmpfm, m_fit_note, family, tmpfm2, m_fit)

  m_post = flexmix::posterior(fit_obj$tmpfit, m_project)

  clusters = abs(round(m_post[, 1]) - 2)

  m_data = rbind(m_fit, m_project)
  reorder_idxs = order(as.numeric(rownames(m_data)))
  m_data = m_data[reorder_idxs, ]
  m_post = rbind(flexmix::posterior(fit_obj$tmpfit), m_post)[reorder_idxs, ]

  list(m_data = m_data, m_post = m_post,
       cluster = c(fit_obj$tmpfit@cluster, clusters)[reorder_idxs])
}


fit_flexmix = function(tmpfm, note, family, tmpfm2, dat.tmp) {

  n.clust = 1
  iter = 0
  while (n.clust < 2 && iter < 5) {
    tmpfit = flexmix(tmpfm, k = 2,
                     model = FLXMRglmfix(fixed = ~note, varFix = FALSE,
                                         family = family),
                     concomitant = tmpfm2, control = list(tol = 1e-8),
                     data = dat.tmp)
    n.clust = length(unique(tmpfit@cluster))
    iter = iter + 1
  }

  list(tmpfit = tmpfit, n.clust = n.clust)
}

fit_to_posterior_obj = function(m_data, fit_obj) {

  list(m_data = m_data, m_post = flexmix::posterior(fit_obj$tmpfit),
       cluster = fit_obj$tmpfit@cluster)
}
