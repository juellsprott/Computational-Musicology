library(tidyverse)
library(plotly)
library(spotifyr)
library(reshape)
library(GGally)
library(compmus)
library(ggpubr)
library(ggplot2)
library(ggplotify)
library(gridExtra)
library(randomForest)

genres <- readRDS(file = "data/genre_playlists.RDS")
tracks <- readRDS(file = "data/artist_playlists.RDS")

# Set seed for reproducibility
library(xgboost)


xgb_model <- xgboost(data =
  as.matrix(genres[, c("danceability", "speechiness",
  "acousticness", "instrumentalness",
   "liveness", "tempo",
    "energy", "loudness", "valence")]),
  label = as.integer(factor(genres$category)), nrounds = 100,
   objective = "multi:softmax",
    num_class = length(unique(genres$category)) + 1)


preds <- predict(xgb_model, as.matrix(tracks[, c("danceability", "speechiness",
 "acousticness", "instrumentalness",
  "liveness", "tempo",
   "energy", "loudness", "valence")]))


cat_levels <- as.character(unique(genres$category))
cat_labels <- cat_levels[preds]

# Add predicted category as a new column in tracks dataframe
tracks$category_pred <- cat_labels


# Get variable importance
imp_plot <- xgb.importance(feature_names = names(genres[, c("danceability", "speechiness", "acousticness", "instrumentalness", "liveness", "tempo", "energy", "loudness", "valence")]), model = xgb_model)

imp_ggplot <- ggplot(imp_plot, aes(x = reorder(Feature, Gain), y = Gain)) + 
  geom_point(size = 2) +
  geom_segment(aes(x = Feature, xend = Feature, y = 0, yend = Gain), color = "gray50") +
  coord_flip() +
  labs(title = 'Variable Importance of XGBoost model',,
       y = 'Importance', x = '') 

imp_ggplot

library(RColorBrewer)

# create a vector of colors using the Paired color palette
# which can accommodate up to 12 categories
my_palette <- brewer.pal(12, "Paired")

classify_scatter <- ggplot() +
  geom_point(data = tracks, aes(x = tempo, y = speechiness, shape = factor(category_pred), color = factor(category)), size = 3) +
  labs(title = "Tempo vs. Speechiness by Category",
       x = "Tempo", y = "Speechiness", color = "Track Category", shape = "Genre Category")

classify_scatter
