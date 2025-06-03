rm(list=ls())
library(shiny)
library(dplyr)
library(leaflet)
library(shinyjs)
library(shinythemes)
library(leaflet.minicharts)
library(shinycssloaders)
load("data.RData")

# Remove data for the whole country
prodRegions <- eco2mix

# Production columns
prodCols <- names(prodRegions)[6:ncol(prodRegions)]

# Create base map
# tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"
# basemap <- leaflet() %>%
#   addTiles(tilesURL) %>%
#   setView(lat = 56.725148, lng = 4.792319, zoom = 05)
# Map is included in the data.RData other wise remove the comment of the above 5 lines

modifycss1<-'#map {height: calc(100vh - 93px) !important;}
      .sea-label {
        background-color: transparent;
        border: none;
        box-shadow: none;
        color: #003366;
        font-weight: bold;
        font-size: 13px;
        text-shadow: 0 0 3px white;
        pointer-events: none;
      }'




inactivity <- "function idleTimer() {
var t = setTimeout(logout, 120000);
window.onmousemove = resetTimer; // catches mouse movements
window.onmousedown = resetTimer; // catches mouse movements
window.onclick = resetTimer;     // catches mouse clicks
window.onscroll = resetTimer;    // catches scrolling
window.onkeypress = resetTimer;  //catches keyboard actions

function logout() {
window.close();  //close the window
}

function resetTimer() {
clearTimeout(t);
t = setTimeout(logout, 120000);  // time is in milliseconds (1000 is 1 second)
}
}
idleTimer();"

ui <-fluidPage(
  shinyjs::useShinyjs(),
  
  singleton(tags$head(
    tags$style(type = "text/css", HTML(modifycss1)),
    
    HTML(
      '
    <title>ONE-BLUE Chemical Occurrence</title>
    
    <!-- Web Fonts -->
    <link rel="stylesheet" type="text/css" href="assets/css/font.css">
    
    <!-- CSS Global Compulsory -->
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
    
    <!-- CSS Header and Footer -->
    <link rel="stylesheet" href="assets/css/headers/header-default.css">
    <link rel="stylesheet" href="assets/css/footers/footer-v1.css">
    
    <!-- CSS Implementing Plugins -->
    <link rel="stylesheet" href="assets/plugins/animate.css">
    <link rel="stylesheet" href="assets/plugins/line-icons/line-icons.css">
    <link rel="stylesheet" href="assets/plugins/font-awesome/css/font-awesome.min.css">
    <link rel="stylesheet" href="assets/plugins/sky-forms-pro/skyforms/css/sky-forms.css">
    <link rel="stylesheet" href="assets/plugins/sky-forms-pro/skyforms/custom/custom-sky-forms.css">
    <!--[if lt IE 9]><link rel="stylesheet" href="assets/plugins/sky-forms-pro/skyforms/css/sky-forms-ie8.css"><![endif]-->
    
    <!-- CSS Theme -->
    <link rel="stylesheet" href="assets/css/theme-colors/default.css">
    <link rel="stylesheet" href="assets/css/theme-colors/blue.css" id="style_color">
    
    <!-- CSS Customization -->
    <link rel="stylesheet" href="assets/css/custom.css">
    
    <div class="wrapper">
    <!--=== Header ===-->
    <div class="header">
    <div class="container">
    
    <!-- Logo -->
    <a class="logo">
    <img src="assets/img/one-blue.png" alt="Logo" style="height: 40px">
    </a>
    <h3><center></center></h3>
    <h4><center><strong>ONE-BLUE Review</strong></h4></center> 
    <h4><center>Spatial distribution of contaminants of emerging concern in seawater</h2></center>
    <!-- Topbar -->
    
    </div><!--/end container-->
    </div><!--/navbar-collapse-->
    </div>
    <!--=== End Header ===-->
    
    '
    ))),
  
  theme = shinytheme("simplex"),
  sidebarLayout(
    sidebarPanel(style = "background: #F8F8F8",
                 selectInput("selectedCompounds", "Contaminant of emerging concern", choices = names(eco2mix)[6:length(names(eco2mix))], multiple = FALSE,  selectize=FALSE, size=30),
                 
                 width = 3),
    
    mainPanel(
      withSpinner(leafletOutput("map", height = "95vh"), type = 6, color = "#007bff")
      
      , width = 9
    )),

  HTML('	
       </body>
       </html>
       ')
)


server <- function(input, output, session) {
  # Reactive: Clean compound values
  compound_data <- reactive({
    req(input$selectedCompounds)
    
    df <- eco2mix %>%
      select(sea_name = contributor, all_of(input$selectedCompounds)) %>%
      filter(!is.na(sea_name))  # Remove NA keys
    
    compound <- input$selectedCompounds[1]
    
    df$clean <- sapply(df[[compound]], function(val) {
      if (is.na(val)) return(NA_real_)
      val <- gsub("<|>", "", val)
      val <- gsub(",", ".", val)
      if (grepl("-", val)) {
        parts <- unlist(strsplit(val, "-"))
        mean(as.numeric(parts), na.rm = TRUE)
      } else {
        as.numeric(val)
      }
    })
    
    avg_df <- df %>%
      group_by(sea_name) %>%
      summarise(value = mean(clean, na.rm = TRUE), .groups = "drop") %>%
      filter(!is.nan(value))
    
    values <- setNames(as.list(avg_df$value), avg_df$sea_name)
    print(values)
    values
  })
  
  # Initial map rendering
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 0, lat = 0, zoom = 2) %>%
      htmlwidgets::onRender("
        function(el, x) {
          var map = this;

          fetch('matched_seas_simplified.geojson')
            .then(response => response.json())
            .then(geojson => {
              window.seaLayer = L.geoJSON(geojson, {
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

          Shiny.addCustomMessageHandler('updateCompoundData', function(message) {
            const compoundData = message.values;

            if (!window.seaLayer) return;

            function getColor(val) {
              if (val === undefined || val === null) return '#cccccc';
              return val > 100 ? '#800026' :
                     val > 50  ? '#BD0026' :
                     val > 20  ? '#E31A1C' :
                     val > 10  ? '#FC4E2A' :
                     val > 5   ? '#FD8D3C' :
                     val > 1   ? '#FEB24C' :
                     val > 0.1 ? '#FED976' :
                                 '#FFEDA0';
            }

            window.seaLayer.eachLayer(function(layer) {
              const name = layer.feature.properties.NAME;
              const val = compoundData[name];
              layer.setStyle({
                fillColor: getColor(val)
              });
              layer.bindTooltip(name + '<br>' + (val !== undefined ? val.toFixed(2) : 'No data'));
            });
          });
        }
      ")
  })
  
  # Observe compound selection and update both colors and legend
  observeEvent(input$selectedCompounds, {
    req(compound_data())
    
    compound_list <- compound_data()
    session$sendCustomMessage("updateCompoundData", list(values = compound_list))
    
    numeric_values <- unlist(compound_list)
    numeric_values <- numeric_values[!is.na(numeric_values)]
    
    leafletProxy("map") %>% clearControls()
    
    if (length(numeric_values) >= 2) {
      pal <- colorNumeric(
        palette = c(
          "#FFEDA0", "#FED976", "#FEB24C", "#FD8D3C",
          "#FC4E2A", "#E31A1C", "#BD0026", "#800026"
        ),
        domain = numeric_values
      )
      
      leafletProxy("map") %>%
        addLegend(
          position = "bottomright",
          pal = pal,
          values = numeric_values,
          title = paste0(input$selectedCompounds[1], " (ng/L)"),
          labFormat = labelFormat(suffix = ""),
          opacity = 1
        )
    }
    
  })
  
}





shinyApp(ui = ui, server = server)