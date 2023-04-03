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


xgb_model <- xgboost(
  data =
    as.matrix(genres[, c(
      "danceability", "speechiness",
      "acousticness", "instrumentalness",
      "liveness", "tempo",
      "energy", "loudness", "valence"
    )]),
  label = as.integer(factor(genres$category)), nrounds = 100,
  objective = "multi:softmax",
  num_class = length(unique(genres$category)) + 1
)


preds <- predict(xgb_model, as.matrix(tracks[, c(
  "danceability", "speechiness",
  "acousticness", "instrumentalness",
  "liveness", "tempo",
  "energy", "loudness", "valence"
)]))



cat_levels <- as.character(unique(genres$category))
cat_labels <- cat_levels[preds]

# Add predicted category as a new column in tracks dataframe
tracks$category_pred <- cat_labels

his <- ggplot(tracks, aes(x = category_pred, fill = category)) +
  geom_bar(position = "dodge2", color = "black") +
  labs(title = "Histogram of genre predictions for all artist tracks",
       x = "Label", y = "Count") 


saveRDS(object = his, file = "data/classify_hist.RDS")


# Get variable importance
imp_plot <- xgb.importance(feature_names = names(genres[, c("danceability", 
"speechiness", "acousticness", "instrumentalness", "liveness", "tempo",
 "energy", "loudness", "valence")]), model = xgb_model)

imp_ggplot <- ggplot(imp_plot, aes(x = reorder(Feature, Gain), y = Gain)) +
  geom_point(size = 2) +
  geom_segment(aes(x = Feature, xend = Feature, y = 0, yend = Gain),
   color = "gray50") +
  coord_flip() +
  labs(
    title = "Variable Importance of XGBoost model", ,
    y = "Importance", x = ""
  )


saveRDS(object = imp_ggplot, file = "data/imp_ggplot.RDS")

