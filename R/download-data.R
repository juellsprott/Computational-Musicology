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

southern <- get_playlist_audio_features("", "18jT9NMRZifv6cMtK2jWD4")
conscious <- get_playlist_audio_features("", "3IU0ZFCSvKNqASPNsWoPuj")
pop <- get_playlist_audio_features("", "5SrYLEPXnsfmK4ZuOCIKKm")
trap <- get_playlist_audio_features("", "60SHtDyagDjPnUpC7x1UD9")
rnb <- get_playlist_audio_features("", "1rLnwJimWCmjp3f0mEbnkY")
melodic <- get_playlist_audio_features("", "2V9SF7DMoOLEvxGVGT4uuU")
chicago <- get_playlist_audio_features("", "71hJ9e25Ub4XZwiE1FZAjI")
gfunk <- get_playlist_audio_features("", "7c1Z3aCJLt7YisQQyXwypK")

genres <-
  bind_rows(southern |> mutate(category = "Southern Rap"),
  conscious |> mutate(category = "Conscious Rap"),
  pop |> mutate(category = "Pop Rap"),
  trap |> mutate(category = "Trap"),
  rnb |> mutate(category = "R&B"),
  melodic |> mutate(category = "Melodic Rap"),
  chicago |> mutate(category = "Chicago Rap"),
  gfunk |> mutate(category = "G Funk"))

saveRDS(object = genres, file = "data/genre_playlists.RDS")
saveRDS(object = my_playlists, file = "data/artist_playlists.RDS")


# Group by category and calculate mean tempo for each category
tempo_summary <- my_playlists |>
  group_by(category) |>
  summarize(mean_tempo = mean(tempo))


# Create the box plot
tempo_box <- ggplot(my_playlists, aes(x = category,
   y = tempo, color = category)) +
  geom_boxplot() +
  geom_jitter(aes(color = category, text = track.name), hoverinfo = "text") +
  labs(x = "Category", y = "Tempo (BPM)") +
  ggtitle("Distribution of tempos by artist/subgenre") +
  scale_x_discrete(limits = tempo_summary$category) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

saveRDS(object = tempo_box, file = "data/tempo_box.RDS")

# histogram of tempos
key_labels <- c("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")

temp_playlist <- bind_rows(
    tyler |> mutate(category = "Tyler, the Creator"),
    vince |> mutate(category = "Vince Staples"),
    mac |> mutate(category = "Mac Miller"),
    frank |> mutate(category = "Frank Ocean"))

hist <- ggplot(temp_playlist, aes(x = key, fill = category)) +
  geom_histogram(binwidth = 1, position="dodge2", color = "black") +
  labs(title = "Histogram of Keys for several outlier playlists",
   x = "Key", y = "Count") +
  scale_x_continuous(breaks = 0:11, labels = key_labels)

saveRDS(object = hist, file = "data/hist.RDS")

# self similarity matrices
runaway <-
get_tidy_audio_analysis("3DK6m7It6Pw857FcQftMds") |>
compmus_align(bars, segments) |>
select(bars) |>
unnest(bars) |>
mutate(
pitches =
    map(segments,
    compmus_summarise, pitches,
    method = "acentre", norm = "manhattan"
    )
) |>
mutate(
timbre =
    map(segments,
    compmus_summarise, timbre,
    method = "mean"
    )
)

saveRDS(object = runaway, file = "data/runaway.RDS")

# heatmap
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

playlist_heatmap <- ggplot(my_playlists_heatmap, aes(x = playlist_name,
 y = variable, fill = value)) + geom_tile(lwd = 1.5,
            linetype = 1) + theme_minimal() +
  theme(axis.text.x = element_text(angle = 90)) +
   labs(y = "Track-level features", x = "Playlist name", fill = "level") +
  ggtitle("Heatmap containing average feature values for each artist")

saveRDS(object = playlist_heatmap, file = "data/playlist_heatmap.RDS")

# parcoord
filtered_list <- my_playlists %>%
                group_by(playlist_name) %>%
                select(playlist_name, energy,
                 acousticness, danceability, valence, track.name) %>%
                    drop_na()

parcoord <- ggparcoord(data = filtered_list,
            columns = 2:5,
            groupColumn = 1,
            alphaLines = .75,
           showPoints = TRUE,
           scale = "globalminmax") +
  facet_wrap(~ playlist_name) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 90),
  legend.position = "none") +
  labs(y = "Feature value", x = "Feature") +
  ggtitle("Parallel coordinates for various features for all tracks")

saveRDS(object = parcoord, file = "data/parcoord.RDS")

# scatter plot
scatter <- ggplot(filtered_list, aes(x = acousticness,
    y = valence, color = playlist_name, label = track.name)) +
    geom_point() +
facet_wrap(~ playlist_name) +
theme(axis.text.x = element_text(angle = 90),
legend.position = "none") + theme_light() +
ggtitle("Acousticness and valence comparison, scatterplot")

saveRDS(object = scatter , file = "data/scatter.RDS")

# chroma comparison
loud <-
  get_tidy_audio_analysis("4KRXcKUesQHKUkX6tHbF01") |>
  select(segments) |>
  unnest(segments) |>
  select(start, duration, pitches) |>
  mutate(pitches = map(pitches, compmus_normalise, "euclidean")) |>
  compmus_gather_chroma() |>
  ggplot(
    aes(
      x = start + duration / 2,
      width = duration,
      y = pitch_class,
      fill = value
    )
  ) +
  geom_tile() +
  labs(x = "Time (s)", y = NULL, fill = "Magnitude") +
  theme_minimal() +
  scale_fill_viridis_c() +
ggtitle("Chromagram for Loud by Mac Miller") +
  theme(plot.title = element_text(hjust = 0.5))

beach <-
get_tidy_audio_analysis("0lqAn1YfFVQ3SdoF7tRZO2") |>
select(segments) |>
unnest(segments) |>
select(start, duration, pitches) |>
mutate(pitches = map(pitches, compmus_normalise, "euclidean")) |>
compmus_gather_chroma() |>
ggplot(
  aes(
    x = start + duration / 2,
    width = duration,
    y = pitch_class,
    fill = value
  )
) +
geom_tile() +
labs(x = "Time (s)", y = NULL, fill = "Magnitude") +
theme_minimal() +
scale_fill_viridis_c() +
ggtitle("Chromagram for THE BEACH by Vince Staples") +
  theme(plot.title = element_text(hjust = 0.5))

saveRDS(object = loud, file = "data/loud.RDS")
saveRDS(object = beach, file = "data/beach.RDS")
