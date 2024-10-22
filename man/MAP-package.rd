\name{MAP-package}
\alias{MAP-package}
\alias{MAP}
\docType{package}
\title{
  MAP: Multimodal Automated Phenotyping
}
\description{
  Electronic health records (EHR) linked with biorepositories are a powerful platform for translational studies. A major bottleneck exists in the ability to phenotype patients accurately and efficiently. Towards that end, we developed an automated high-throughput phenotyping method integrating International Classification of Diseases (ICD) codes and narrative data extracted using natural language processing (NLP). Specifically, our proposed method, called MAP (Map Automated Phenotyping algorithm), fits an ensemble of latent mixture models on aggregated ICD and NLP counts along with healthcare utilization. The MAP algorithm yields a predicted probability of phenotype for each patient and a threshold for classifying subjects with phenotype yes/no (See Katherine P. Liao, et al. (2019) doi:10.1093/jamia/ocz066.)
}
\details{
  \tabular{ll}{
    Package: \tab MAP\cr
    Type: \tab Package\cr
    Version: \tab 1.3-0\cr
    Date: \tab 2021-01-31\cr
    License: GPL>=2 \cr
  }
}

\section{Overview}{Electronic health records linked with biorepositories are a powerful platform for translational studies. A major bottleneck exists in the ability to phenotype patients accurately and efficiently. The objective of this study was to develop an automated high-throughput phenotyping method integrating International Classification of Diseases (ICD) codes and narrative data extracted using natural language processing (NLP).We developed a mapping method for automatically identifying relevant ICD and NLP concepts for a specific phenotype leveraging the Unified Medical Language System. Along with health care utilization, aggregated ICD and NLP counts were jointly analyzed by fitting an ensemble of latent mixture models. The multimodal automated phenotyping (MAP) algorithm yields a predicted probability of phenotype for each patient and a threshold for classifying participants with phenotype yes/no. The algorithm was validated using labeled data for 16 phenotypes from a biorepository and further tested in an independent cohort phenome-wide association studies (PheWAS) for 2 single nucleotide polymorphisms with known associations.
}


\section{Identifying the main ICD and NLP features for phenotypes}{To define a target phenotype, we first determine the main ICD code associated with the phenotype. This code is either specified by the researcher or chosen from a PheWAS code in the catalog to use the corresponding ICD mapping. The PheWAS catalog groups ICD codes into clinically relevant categories, such as bacterial pneumonia, which includes different types of pneumonia each linked to a specific code. We aggregate multiple or higher-level PheWAS codes to represent broader categories, like diabetes, which includes both type 1 and type 2 diabetes. For the selected ICD codes, we aggregate them to represent the main ICD feature and then calculate the total count of this main ICD feature in the dataset. We also map all ICD-10 codes to ICD-9 using the General Equivalence Mapping provided by the Centers for Medicare & Medicaid Services. Each ICD-9 code is counted once per day to minimize the impact of dual coding.
  
  For the phenotype NLP feature, we identify the medical concepts by mapping relevant clinical terms to their unique identifiers (CUIs) in the Unified Medical Language System (UMLS). This mapping process involves identifying CUIs through three steps: directly mapping ICD-9 codes to CUIs, mapping ICD-9 descriptions to CUIs with exact matches, and mapping phenotype descriptions to CUIs with exact matches. Although the first two mapping steps usually yield identical lists, the second step can sometimes produce a larger list due to the potential for a single ICD-9 description to map to multiple concepts. The compiled list of CUIs represents each PheWAS code.

The narrative text notes from all participants are processed next. Using the CUI list for each PheWAS code, we count each mention of the clinical terms linked to the CUIs. If a phenotype is defined by multiple PheWAS codes, we sum the counts to get the overall NLP count for the phenotype. The Narrative Information Linear Extraction (NILE) system is used to extract these concepts. From previous studies, we know the NLP features extracted are consistent regardless of the NLP platform used.

We also adjust for health care utilization by counting the total number of narrative notes for each patient. This count serves as a proxy for health care utilization in the MAP algorithm. Moreover, we log-transform these counts and other features to enhance model robustness and predictive accuracy.
}


\section{Unsupervised MAP prediction}{Using data on the ICD and NLP counts and their log-transformed versions, we fit mixture models to each feature to estimate the likelihood of a patient having the phenotype. We use both Poisson and normal mixture models depending on which provides a better fit for the observed data. These models help adjust for health care utilization noise that could affect feature predictions.
  
  To predict the likelihood of a phenotype, we compute the posterior probabilities for each patient using the fitted models. We then estimate the phenotyping prevalence by averaging these probabilities. Finally, we classify participants as having or not having the phenotype based on whether their predicted probability exceeds the average prevalence threshold.
}


\author{
  Author: XXX
  Maintainer: XXX <XXX>
  Contributor: XXX
}

\keyword{package}