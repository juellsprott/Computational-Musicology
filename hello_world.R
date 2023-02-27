library(tidyverse)
library(spotifyr)
library(reshape)
library(GGally)


j_cole <- get_playlist_audio_features("", "37i9dQZF1DXcGnc6d1f20P")
kanye <- get_playlist_audio_features("", "37i9dQZF1DZ06evO3nMr04")
jay_z <- get_playlist_audio_features("", "37i9dQZF1DX7jGZjyDa8rI")
cudi <- get_playlist_audio_features("", "37i9dQZF1DZ06evO04TCIU")
tyler <- get_playlist_audio_features("", "37i9dQZF1DX8IzjtXj8ThV")
vince <- get_playlist_audio_features("", "37i9dQZF1DZ06evO3Cn7Uc")
swae <- get_playlist_audio_features("", "37i9dQZF1DZ06evO0SmMhV")
meek <- get_playlist_audio_features("", "37i9dQZF1DZ06evO18pFbq")
mac <- get_playlist_audio_features("", "37i9dQZF1DZ06evO2NufN6")
rocky <- get_playlist_audio_features("", "37i9dQZF1DX2EykupcJRsV")
savage <- get_playlist_audio_features("", "37i9dQZF1DWYojpWKpDMGi")
gambino <- get_playlist_audio_features("", "37i9dQZF1DZ06evO4aKvZe")
drake <- get_playlist_audio_features("", "37i9dQZF1DX7QOv5kjbU68")
metro <- get_playlist_audio_features("", "37i9dQZF1DZ06evO06Ki7m")
travis <- get_playlist_audio_features("", "37i9dQZF1DWUgX5cUT0GbU")
pop_smoke <- get_playlist_audio_features("", "37i9dQZF1DZ06evO04kFZs")
frank <- get_playlist_audio_features("", "37i9dQZF1DXdyjMX5o2vCq")


my_playlists <-
  bind_rows(kanye |> mutate(category = "Kanye"),
    j_cole |> mutate(category = "J Cole"),
    jay_z |> mutate(category = "Jay Z"),
    cudi |> mutate(category = "Kid Cudi"),
    tyler |> mutate(category = "Tyler, the Creator"),
    vince |> mutate(category = "Vince Staples"),
    swae |> mutate(category = "Swae Lee"),
    meek |> mutate(category = "Meek Mill"),
    mac |> mutate(category = "Mac Miller"),
    rocky |> mutate(category = "A$AP Rocky"),
    savage |> mutate(category = "21 Savage"),
    drake |> mutate(category = "Drake"),
    metro |> mutate(category = "Mwtro Boomin"),
    travis |> mutate(category = "Travis Scott"),
    pop_smoke |> mutate(category = "Pop Smoke"),
    frank |> mutate(category = "Frank Ocean"))


# we research valence, speechiness,
# acousticness, liveness, dancability and energy

my_playlists_mean <- my_playlists %>%
 group_by(playlist_name) %>%
 summarize(mean_energy = mean(energy), mean_speech = mean(speechiness),
            mean_valence = mean(valence),
            mean_acousticness = mean(acousticness),
            mean_liveness = mean(liveness),
            mean_danceability = mean(danceability)) %>%
drop_na()

playlist_df <- as.data.frame(my_playlists_mean)

my_playlists_heatmap <- melt(playlist_df)

my_playlists_heatmap

ggplot(my_playlists_heatmap, aes(x = playlist_name,
 y = variable, fill = value)) + geom_tile(lwd = 1.5,
            linetype = 1) +
  theme(axis.text.x = element_text(angle = 90)) +
   labs(y = "Track-level features", x = "Playlist name", fill = "level") +
  ggtitle("Heatmap containing average feature values for each artist")


filtered_list <- my_playlists %>%
                group_by(playlist_name) %>%
                select(playlist_name, energy,
                 acousticness, danceability, valence) %>%
                    drop_na()
filtered_list

ggparcoord(data = filtered_list,
            columns = 2:5,
            groupColumn = 1,
            alphaLines = .75,
           showPoints = TRUE,
           scale = "globalminmax") +
  facet_wrap(~ playlist_name) +
  theme(axis.text.x = element_text(angle = 90),
  legend.position = "none") +
  labs(y = "Feature value", x = "Feature") +
  ggtitle("Parallel coordinates for various features for all tracks")

  ggplot(filtered_list, aes(x = acousticness,
     y = valence, color = playlist_name)) +
      geom_point() +
  facet_wrap(~ playlist_name) +
  theme(axis.text.x = element_text(angle = 80),
  legend.position = "none") +
  ggtitle("Acousticness and valence comparison, scatterplot")
