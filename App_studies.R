library(shiny)
library(leaflet)
library(readxl)
library(sf)
library(shinycssloaders)
library(leafem)
library(geojsonio)
library(dplyr)

# Load point dataset
data <- read_excel("Chemical occurrence review ONE-BLUE_VO_NA.xlsx", sheet = "Studies")
data <- data[,c("Analytes (ng/L)","Latitude","Longitude","Water Body2","Ocean2","Water Body_Standardized")]
data <- data[!is.na(data$Longitude), ]
data$Latitude <- as.numeric(data$Latitude)
data$Longitude <- as.numeric(data$Longitude)

#Create matched_seas.geojson
#seas <- st_read("sf/World_Seas_IHO_v3.shp", quiet = TRUE)
#north_sea <- seas[seas$NAME == "North Sea", ]
#matched_seas <- seas[seas$NAME %in% data$`Water Body_Standardized`, ]
#matched_seas$NAME
# Reproject to Web Mercator (EPSG:3857)
#matched_seas_proj <- st_transform(matched_seas, crs = 3857)
# Simplify geometry with a 5 km tolerance
#matched_seas_simplified <- st_simplify(matched_seas_proj, dTolerance = 5000, preserveTopology = TRUE)
# Reproject back to WGS84 for GeoJSON export
#matched_seas_simplified <- st_transform(matched_seas_simplified, crs = 4326)
# Save as GeoJSON for fast loading in Shiny
#st_write(matched_seas_simplified, "www/matched_seas_simplified.geojson", driver = "GeoJSON", delete_dsn = TRUE)
#matched_seas2 <- st_read("www/matched_seas_simplified.geojson", quiet = TRUE)

# Convert markers to sf object
#points_sf <- st_as_sf(data, coords = c("Longitude", "Latitude"), crs = 4326)
#points_sf <- points_sf %>%
#  mutate(popup = paste0(
#    "<strong>Reference:</strong> ", `Analytes (ng/L)`, "<br>",
#    "<strong>Ocean:</strong> ", Ocean2
#  ))
#st_write(points_sf, "www/points.geojson", driver = "GeoJSON", delete_dsn = TRUE)


ui <- fluidPage(
  titlePanel("Chemical occurrence"),
  
  tags$head(
    tags$style(HTML("
      .sea-label {
        background-color: transparent;
        border: none;
        box-shadow: none;
        color: #003366;
        font-weight: bold;
        font-size: 13px;
        text-shadow: 0 0 3px white;
        pointer-events: none;
      }
    "))
  ),
  
  withSpinner(leafletOutput("map", height = "90vh"), type = 6, color = "#007bff")
)


server <- function(input, output, session) {

  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      
      htmlwidgets::onRender("
  function(el, x) {
    var map = this;

    // Load and draw simplified sea polygons + labels
    fetch('matched_seas_simplified.geojson')
      .then(response => response.json())
      .then(geojson => {
        L.geoJSON(geojson, {
          style: {
            color: '#2b83ba',
            weight: 1,
            fillColor: '#a6bddb',
            fillOpacity: 0.2
          },
          interactive: false,
          onEachFeature: function(feature, layer) {
            if (feature.properties && feature.properties.NAME) {
              var label = L.tooltip({
                permanent: true,
                direction: 'center',
                className: 'sea-label'
              })
              .setContent(feature.properties.NAME)
              .setLatLng(layer.getBounds().getCenter());

              map.addLayer(label);
            }
          }
        }).addTo(map);
      });

    // Load and draw sample points with popups
    fetch('points.geojson')
      .then(response => response.json())
      .then(geojson => {
        L.geoJSON(geojson, {
          pointToLayer: function(feature, latlng) {
            return L.circleMarker(latlng, {
              radius: 5,
              color: '#1c1c94',
              fillOpacity: 0.7
            });
          },
          onEachFeature: function(feature, layer) {
            if (feature.properties && feature.properties.popup) {
              layer.bindPopup(feature.properties.popup);
            }
          }
        }).addTo(map);
      });
  }
")
    
    
  })
  
  
  
  
}

shinyApp(ui, server)
