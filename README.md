# MAP: Multimodal Automated Phenotyping

Electronic health records (EHR) linked with biorepositories are a powerful platform for translational studies. A major bottleneck exists in the ability to phenotype patients accurately and efficiently. Towards that end, we developed an automated high-throughput phenotyping method integrating International Classification of Diseases (ICD) codes and narrative data extracted using natural language processing (NLP). Specifically, our proposed method, called MAP (Map Automated Phenotyping algorithm), fits an ensemble of latent mixture models on aggregated ICD and NLP counts along with healthcare utilization. The MAP algorithm yields a predicted probability of phenotype for each patient and a threshold for classifying subjects with phenotype yes/no (See Katherine P. Liao, et al. (2019) <doi:10.1101/587436>.).

# Installation

## Stable Version

Install stable version from CRAN:

```r
install.packages("MAP")
```

## Development Version

Install development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("celehs/MAP")
```

# Reference

K. P. Liao, J. Sun, T. A. Cai, ..., T. Cai (2019). [High-throughput Multimodal Automated Phenotyping (MAP) with Application to PheWAS](https://doi.org/10.1101/587436).
