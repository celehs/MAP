% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MAP.R
\name{MAP}
\alias{MAP}
\title{MAP algorithm}
\usage{
MAP(
  mat = NULL,
  note = NULL,
  yes.con = FALSE,
  full.output = FALSE,
  subset_sample = FALSE,
  subset_sample_size = 5000,
  verbose = TRUE
)
}
\arguments{
\item{mat}{Count data (sparse matrix). One of the columns has to be ICD
data with name being ICD.}

\item{note}{Note count (sparse matrix) indicating healthcare utilization.}

\item{yes.con}{A logical variable indicating if concomitant is desired. Not
used for now.}

\item{full.output}{A logical variable indicating if full outputs are
desired.}

\item{subset_sample}{Logical, perform fit on a subset of patients and
project remaining.}

\item{subset_sample_size}{If subset_sample TRUE, number of patients on which
to perform the fit (default 50k).}

\item{verbose}{Print model information}
}
\value{
Returns a list with following objects:
        \item{scores}{Indicates predicted probabilities.}
        \item{cut.MAP}{The cutoff value that can be used to derive binary
        phenotypes.}
}
\description{
Main function to perform MAP algorithm to calculate predicted
probabilities of positive phenotype for each patient
based on NLP and ICD counts adjusted for healthcare utilization.
For large number of patients (>50k) it may take very long to compute,
so a subset_sample parameter is provided to perform the fit on a subset of
patients and project the remaining. The subset_sample_size controls the
maximum number of patients on which to perform the fit.
}
\examples{
## simulate data to test the algorithm
n = 400
ICD = c(rpois(n/4,10), rpois(n/4,1), rep(0,n/2) )
NLP = c(rpois(n/4,10), rpois(n/4,1), rep(0,n/2) )
mat = Matrix(data=cbind(ICD,NLP),sparse = TRUE)
note = Matrix(rpois(n,10)+5,ncol=1,sparse = TRUE)
res = MAP(mat = mat,  note=note)
head(res$scores)
res$cut.MAP

}
\references{
High-throughput Multimodal Automated Phenotyping (MAP) with
Application to PheWAS. Katherine P. Liao, Jiehuan Sun,
Tianrun A. Cai, Nicholas Link, Chuan Hong, Jie Huang, Jennifer Huffman,
Jessica Gronsbell, Yichi Zhang, Yuk-Lam Ho, Victor Castro, Vivian Gainer,
Shawn Murphy, Christopher J. O’Donnell, J. Michael Gaziano, Kelly Cho,
Peter Szolovits, Isaac Kohane, Sheng Yu, and Tianxi Cai
with the VA Million Veteran Program (2019) <doi:10.1101/587436>.
}
