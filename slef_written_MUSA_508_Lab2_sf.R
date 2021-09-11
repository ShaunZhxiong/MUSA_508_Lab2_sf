library(tidyverse)
library(tidycensus)
library(sf)
library(tmap) # mapping, install if you don't have it
set.seed(717)


census_api_key("b33ec1cb4da108659efd12b3c15412988646cbd8", overwrite = TRUE,install=TRUE)
acs_vars <- c("B01001_001E", # ACS total Pop estimate
              "B25002_001E", # Estimate of total housing units
              "B25002_003E", # Number of vacant housing units
              "B19013_001E", # Median HH Income ($)
              "B02001_002E", # People describing themselves as "white alone"
              "B06009_006E") # Total graduate or professional degree
myTracts <- c("42101023500", 
              "42101023600", 
              "42101023700", 
              "42101025300", 
              "42101025400",
              "42101025500", 
              "42101025600", 
              "42101038800")
acsTractsPHL.2016.sf <- get_acs(geography = "tract",
                                year = 2016, 
                                variables = acs_vars, 
                                geometry = TRUE, 
                                state = "PA", 
                                county = "Philadelphia", 
                                output = "wide") %>% 
  dplyr::select (GEOID, NAME, all_of(acs_vars)) %>%
  rename (total_pop.2016 = B01001_001E,
          total_HU.2016 = B25002_001E,
          total_vacant.2016 = B25002_003E,
          med_HH_Income.2016 = B19013_001E,
          total_White.2016 = B02001_002E,
          total_GradDeg.2016 = B06009_006E) %>%
  mutate(vacancyPct.2016 = total_vacant.2016/total_HU.2016,
         pctWhite.2016 = total_White.2016/total_pop.2016) %>%
  mutate(mtAiry = ifelse(GEOID %in% myTracts, "MT AIRY", "REST OF PHILADELPHIA"))

#to illustrate the function of 'st_as_sf(crs = 4326)' in the 1st class
# the work here is to transfer geographic CRS:NAD83 to CRS:4326

### THE DATA DOWNLOADED FROM ACS IS CRS:NAD83. This CRS was automatically set by `{tidycensus}` because it knows where the data comes from.
### BUT the above case will not be the ordinary case,
## if you load a CSV with point coordinates, `{sf}` will not guess as to which CRS it is.

PHL_data <- data.frame(point_ID = seq(1,300,1),
                       variable1 = rnorm(300,0,1)) %>% 
  mutate(latitude  = sample(seq(39.852,40.052,0.001),n(), replace = TRUE),
         longitude = sample(seq(-75.265,-75.065,0.001),n(), replace = TRUE))

PHL_data.sf <- PHL_data %>% 
  st_as_sf(coords = c("longitude", "latitude"),
           crs = "EPSG:4326") 