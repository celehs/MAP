from rocker/shiny-verse:4.4.1

run R -e "install.packages('pROC')"

add ./ /map

run R -e "devtools::install('map')"
