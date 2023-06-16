library(ordinal)
library(tidyverse)
library(sp)
library(raster)
library(leaflet)

# Generate simulated data with an ID column
set.seed(123)
survey_data <- data.frame(
  ID = paste0("ID", 1:100),
  x1 = rnorm(100),
  x2 = rnorm(100),
  x3 = rnorm(100),
  y = ordered(sample(1:5, 100, replace = TRUE), labels = c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree"))
)

# Fit multivariate ordinal regression model
fit <- clm(y ~ x1 + x2 + x3, data = survey_data)

# Join the output of the regression to a shapefile based on the IDs
shapefile <- readOGR(dsn = ".", layer = "your_shapefile.shp")
shapefile_data <- data.frame(ID = row.names(shapefile), row.names = NULL)
predicted_probs <- survey_data %>% 
  select(ID) %>% 
  left_join(predict(fit, type = "prob"), by = "ID") %>% 
  left_join(shapefile_data, by = "ID")
  
# Use ggplot2 to create a visualization of the predicted probabilities
ggplot(predicted_probs, aes(x = category, y = x1, fill = prob)) +
  geom_col(position = "dodge") +
  facet_wrap(~x2, ncol = 3) +
  scale_fill_gradient(low = "white", high = "blue") +
  labs(x = "Response category", y = "x1", fill = "Probability")
  
# Interpolate predicted probabilities using IDW
points <- SpatialPoints(predicted_probs[, c("x1", "x2")])
grid <- expand.grid(x = seq(min(predicted_probs$x1), max(predicted_probs$x1), length.out = 100), 
                     y = seq(min(predicted_probs$x2), max(predicted_probs$x2), length.out = 100))
gridded_points <- SpatialPoints(grid)
idw <- idw(points, predicted_probs$Agree, gridded_points)

# Create a plot in leaflet of the final output
leaflet() %>%
  addTiles() %>%
  addRasterImage(raster = idw, colors = colorRamp(c("white", "blue")), opacity = 0.8) %>%
  addMarkers(data = survey_data, ~x1, ~x2, popup = ~as.character(ID))
