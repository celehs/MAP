from rocker/shiny-verse:4.4.1

run apt-get update && \
  apt-get install -y --no-install-recommends texlive texlive-latex-recommended texlive-fonts-extra qpdf

run R -e "install.packages('pROC')"

add ./ /map

run R -e "devtools::install('map')"
