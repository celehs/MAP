
# MAP: Multimodal Automated Phenotyping

[![CRAN version](https://www.r-pkg.org/badges/version/MAP)](https://cran.r-project.org/package=MAP)
[![CRAN total downloads](https://cranlogs.r-pkg.org/badges/grand-total/MAP)](https://cran.r-project.org/package=MAP)
[![CRAN monthly downloads](https://cranlogs.r-pkg.org/badges/MAP)](https://cran.r-project.org/package=MAP)

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

## Identifying the main ICD and NLP features for phenotypes

To define a target phenotype, we first determine the main ICD code associated with the phenotype. This code is either specified by the researcher or chosen from a PheWAS code in the catalog to use the corresponding ICD mapping. The PheWAS catalog groups ICD codes into clinically relevant categories, such as bacterial pneumonia, which includes different types of pneumonia each linked to a specific code. We aggregate multiple or higher-level PheWAS codes to represent broader categories, like diabetes, which includes both type 1 and type 2 diabetes. For the selected ICD codes, we aggregate them to represent the main ICD feature and then calculate the total count of this main ICD feature in the dataset. We also map all ICD-10 codes to ICD-9 using the General Equivalence Mapping provided by the Centers for Medicare & Medicaid Services. Each ICD-9 code is counted once per day to minimize the impact of dual coding.

For the phenotype NLP feature, we identify the medical concepts by mapping relevant clinical terms to their unique identifiers (CUIs) in the Unified Medical Language System (UMLS). This mapping process involves identifying CUIs through three steps: directly mapping ICD-9 codes to CUIs, mapping ICD-9 descriptions to CUIs with exact matches, and mapping phenotype descriptions to CUIs with exact matches. Although the first two mapping steps usually yield identical lists, the second step can sometimes produce a larger list due to the potential for a single ICD-9 description to map to multiple concepts. The compiled list of CUIs represents each PheWAS code.

The narrative text notes from all participants are processed next. Using the CUI list for each PheWAS code, we count each mention of the clinical terms linked to the CUIs. If a phenotype is defined by multiple PheWAS codes, we sum the counts to get the overall NLP count for the phenotype. The Narrative Information Linear Extraction (NILE) system is used to extract these concepts. From previous studies, we know the NLP features extracted are consistent regardless of the NLP platform used.

We also adjust for health care utilization by counting the total number of narrative notes for each patient. This count serves as a proxy for health care utilization in the MAP algorithm. Moreover, we log-transform these counts and other features to enhance model robustness and predictive accuracy.

## Unsupervised MAP prediction

Using data on the ICD and NLP counts and their log-transformed versions, we fit mixture models to each feature to estimate the likelihood of a patient having the phenotype. We use both Poisson and normal mixture models depending on which provides a better fit for the observed data. These models help adjust for health care utilization noise that could affect feature predictions.

To predict the likelihood of a phenotype, we compute the posterior probabilities for each patient using the fitted models. We then estimate the phenotyping prevalence by averaging these probabilities. Finally, we classify participants as having or not having the phenotype based on whether their predicted probability exceeds the average prevalence threshold.

## Citation

Liao, K. P., Sun, J., Cai, T. A., Link, N., Hong, C., Huang, J.,
Huffman, J. E., Gronsbell, J., Zhang, Y., Ho, Y. L., Castro, V., Gainer,
V., Murphy, S. N., O’Donnell, C. J., Gaziano, J. M., Cho, K., Szolovits,
P., Kohane, I. S., Yu, S., & Cai, T. (2019). High-throughput multimodal
automated phenotyping (MAP) with application to PheWAS. Journal of the
American Medical Informatics Association : JAMIA, 26(11), 1255–1262.
<https://doi.org/10.1093/jamia/ocz066>
