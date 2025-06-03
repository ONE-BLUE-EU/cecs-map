\name{ONE-BLUE Chemical Occurrence Viewer}
\alias{ONE-BLUE Chemical Occurrence Viewer}
\title{Interactive Viewer for Contaminants of Emerging Concern in Seawater}
\description{
  A Shiny application for visualizing the spatial distribution of contaminants of emerging concern (CECs) in seawater.
  The application is part of the ONE-BLUE project funded by the Horizon Europe programme (Grant No. 101134929).
}
\details{
  The application provides an interactive Leaflet map that displays:
  \itemize{
    \item Sea regions with average concentrations of selected contaminants
    \item Sampling points with metadata
    \item A dynamic user interface for selecting a contaminant to display
    \item Automatic color-coded legends based on contaminant values
  }

  Data sources include a preloaded RData file (\code{data.RData}) with a data frame (\code{eco2mix}) containing CEC measurements.

  The map uses two GeoJSON layers:
  \itemize{
    \item \code{matched_seas_simplified.geojson}: marine region boundaries
    \item \code{points.geojson}: sampling point coordinates and popups
  }
}
\usage{
shiny::runApp()
}

\references{
  ONE-BLUE Project: \url{https://cordis.europa.eu/project/id/101134929}
}
\examples{
## Not run:
# Load the app with:
shiny::runApp()
## End(Not run)
}
\seealso{
  \code{\link[shiny]{shiny}}, \code{\link[leaflet]{leaflet}}
}
