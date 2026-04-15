library(ggplot2)
library(dplyr)
library(scales)

csv_path <- "experiment_output/results.csv"
df <- read.csv(csv_path, stringsAsFactors = FALSE)

df_m <- df |>
  filter(domain == "mitchell") |>
  mutate(
    cells = as.integer(sub("(\\d+)x(\\d+)", "\\1", grid)) *
            as.integer(sub("(\\d+)x(\\d+)", "\\2", grid)),
    grid_label = gsub("x", "\u00d7", grid)
  )

df_rules <- df_m |>
  distinct(cells, grid_label, encoding, src_n_rules_src) |>
  mutate(encoding = dplyr::recode(encoding,
    "binary"     = "Codificaci\u00f3n binaria",
    "factorized" = "Codificaci\u00f3n factorizada"
  )) |>
  arrange(cells)

# Tabla de etiquetas ordenadas para el eje X log
cell_labels <- df_rules |>
  distinct(cells, grid_label) |>
  arrange(cells)

pal <- c(
  "Codificaci\u00f3n binaria"     = "#0072B2",
  "Codificaci\u00f3n factorizada" = "#E69F00"
)

p <- ggplot(df_rules,
            aes(x = cells, y = src_n_rules_src,
                color = encoding, group = encoding)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.5) +
  # Eje X log10: puntos uniformemente espaciados, sin ticks menores fantasma
  scale_x_log10(
    breaks       = cell_labels$cells,
    labels       = cell_labels$grid_label,
    minor_breaks = NULL
  ) +
  scale_y_log10(labels = label_comma()) +
  scale_color_manual(values = pal) +
  labs(
    x     = "Tama\u00f1o del grid (escala logar\u00edtmica)",
    y     = "N\u00famero de reglas (escala logar\u00edtmica)",
    color = NULL
  ) +
  theme_classic(base_size = 12) +
  theme(
    legend.position        = "top",
    axis.text.x            = element_text(angle = 45, hjust = 1),
    # Cuadrícula horizontal sutil, estilo journals IEEE/Springer
    panel.grid.major.y     = element_line(color = "grey88", linewidth = 0.4),
    panel.grid.minor.y     = element_blank(),
    panel.grid.major.x     = element_blank()
  )

ggsave("figuras/reglas-celdas.pdf", p, width = 6, height = 4)
message("Figura guardada: figuras/reglas-celdas.pdf")
