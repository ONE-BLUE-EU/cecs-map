# 🌊 ONE-BLUE Chemical Occurrence Viewer

This Shiny application visualizes the **spatial distribution of contaminants of emerging concern (CECs)** in seawater, using data from predefined marine regions. The app was developed within the framework of the **ONE-BLUE** project, funded by the European Union under the **Horizon Europe** programme.

## 📦 Requirements

### R packages

Make sure the following packages are installed:

```r
install.packages(c(
  "shiny", "dplyr", "leaflet", "shinyjs", 
  "shinythemes", "shinycssloaders"
))
remotes::install_github("rstudio/leaflet.minicharts")
