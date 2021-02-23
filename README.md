
# MAP: Multimodal Automated Phenotyping

[![CRAN](https://www.r-pkg.org/badges/version/MAP)](https://CRAN.R-project.org/package=MAP)

## Overview

Electronic health records (EHR) linked with biorepositories are a
powerful platform for translational studies. A major bottleneck exists
in the ability to phenotype patients accurately and efficiently. Towards
that end, we developed an automated high-throughput phenotyping method
integrating International Classification of Diseases (ICD) codes and
narrative data extracted using natural language processing (NLP).
Specifically, our proposed method, called MAP (Map Automated Phenotyping
algorithm), fits an ensemble of latent mixture models on aggregated ICD
and NLP counts along with healthcare utilization. The MAP algorithm
yields a predicted probability of phenotype for each patient and a
threshold for classifying subjects with phenotype yes/no (See Katherine
P. Liao, et al. (2019) <doi:10.1093/jamia/ocz066>.).

## Installation

Install stable version from CRAN:

``` r
install.packages("MAP")
```

Install development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("celehs/MAP")
```

## Citation

Liao, K. P., Sun, J., Cai, T. A., Link, N., Hong, C., Huang, J.,
Huffman, J. E., Gronsbell, J., Zhang, Y., Ho, Y. L., Castro, V., Gainer,
V., Murphy, S. N., O’Donnell, C. J., Gaziano, J. M., Cho, K., Szolovits,
P., Kohane, I. S., Yu, S., & Cai, T. (2019). High-throughput multimodal
automated phenotyping (MAP) with application to PheWAS. Journal of the
American Medical Informatics Association : JAMIA, 26(11), 1255–1262.
<https://doi.org/10.1093/jamia/ocz066>
