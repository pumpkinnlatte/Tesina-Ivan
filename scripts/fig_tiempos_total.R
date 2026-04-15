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

df_time <- df_m |>
  filter(status == "OK") |>
  mutate(
    backend_label = dplyr::recode(backend,
      "ddnnf"    = "d-DNNF",
      "darwiche" = "Darwiche",
      "sdd"      = "SDD"
    ),
    enc_label = dplyr::recode(encoding,
      "binary"     = "Binaria",
      "factorized" = "Factorizada"
    ),
    series = paste(enc_label, backend_label, sep = " \u2014 ")
  )

backend_levels <- c("d-DNNF", "Darwiche", "SDD")
df_time$backend_label <- factor(df_time$backend_label, levels = backend_levels)

pal_backend <- c(
  "d-DNNF"   = "#0072B2",
  "Darwiche" = "#E69F00",
  "SDD"      = "#009E73"
)
ltype_enc <- c("Binaria" = "solid", "Factorizada" = "dashed")

# Etiquetas del eje X: todos los breaks pero solo se muestran las 5 posiciones
# bien separadas para evitar solapamiento; los otros ticks quedan en blanco
cell_labels <- df_m |>
  distinct(cells, grid_label) |>
  arrange(cells)

# Posiciones que tendrán etiqueta visible (aproximadamente potencias de 2 en dimensión)
cells_labeled <- c(6, 16, 64, 256, 1024)   # 2x3, 4x4, 8x8, 16x16, 32x32
cell_labels <- cell_labels |>
  mutate(label_show = ifelse(cells %in% cells_labeled, grid_label, ""))

# Posición horizontal de la anotación TIMEOUT
x_annot <- exp(mean(log(range(df_time$cells)))) * 1.5

p <- ggplot(df_time,
            aes(x = cells, y = t_total_mean,
                color = backend_label,
                linetype = enc_label,
                group = series)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_hline(yintercept = 400, linetype = "dotted",
             color = "grey40", linewidth = 0.8) +
  annotate("text",
           x     = x_annot,
           y     = 520,
           label = "TIMEOUT (400 s)",
           color = "grey40",
           size  = 3.2) +
  scale_x_log10(
    breaks      = cell_labels$cells,
    labels      = cell_labels$label_show,
    minor_breaks = NULL
  ) +
  scale_y_log10(labels = label_comma()) +
  scale_color_manual(values = pal_backend, breaks = backend_levels) +
  scale_linetype_manual(values = ltype_enc) +
  labs(
    x        = "Tama\u00f1o del grid",
    y        = expression(t[total]~"(s)"),
    color    = "Backend",
    linetype = "Codificaci\u00f3n"
  ) +
  theme_classic(base_size = 12) +
  theme(
    legend.position        = "bottom",
    legend.box             = "horizontal",
    legend.margin          = margin(t = 2),
    axis.text.x            = element_text(angle = 45, hjust = 1),
    panel.grid.major.y     = element_line(color = "grey88", linewidth = 0.4),
    panel.grid.minor       = element_blank(),
    panel.grid.major.x     = element_blank()
  )

ggsave("figuras/tiempos-total.pdf", p, width = 7, height = 5.5)
message("Figura guardada: figuras/tiempos-total.pdf")
