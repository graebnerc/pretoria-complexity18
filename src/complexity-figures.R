# This file creates the graphs as shown on slides
# 20, 21, 29, and 31
# It assumes that the working directory has a folder 'output' in which graphs can be stored
# It also ssumes the relevant data lies in a folder 'data' in the working directory
#
# Author: Claudius Graebner
# Email: claudius@claudius-graebner.com
#
# This script is part of the material for the methodological workshop
# 'Measures of economic complexity - Potentials and limitations for development studies'
# held on September 11 by Claudius Graebner during the DAAD Workshop
# 'Sustainable growth and diversification' in Pretoria
#
# The data on product complexity has been obtained from here:
# https://intl-atlas-downloads.s3.amazonaws.com/index.html
# The macroeconomic data has been obtained from the WDI
#
# Note that the product data is currently in a zip archive

rm(list = ls())
library(tidyverse)
library(data.table)
library(countrycode)
library(viridis)
library(EconGeo)
library(ggpubr)

macro_dat_file <- "data/macro_data.csv"
product_dat_file <- "data/country_hsproduct_year.csv"
country_list_file <- "data/country_list.csv"

country_list <- fread(country_list_file)$country
macro_dat <- fread(macro_dat_file)

dat <- fread(product_dat_file,
  colClasses = c("character", "integer", rep("double", 10), rep("character", 2))
)

make_plots <- T
expl_year <- 2008
expl_countries <- c("USA", "DEU", "ZAF", "CHN", "IND", "KEN")

# Create the motivating graphs from slides 20 and 21

macro_dat_US <- macro_dat %>%
  filter(country == "USA") %>%
  select(one_of("GDP_PC", "year")) %>%
  rename(GDP_PC_US = GDP_PC)

macro_dat_plot <- macro_dat %>%
  left_join(macro_dat_US, by = "year") %>%
  mutate(
    comp_usa = GDP_PC_US / GDP_PC,
    GDP_PC = GDP_PC / 1000
  )

if (make_plots) {
  gdp_pc_plot <- ggplot(macro_dat_plot, aes(x = year, y = GDP_PC, color = country)) +
    geom_line() + xlab("Year") + ylab("GDP per capita (1000 PPP)") +
    scale_x_continuous(limits = c(1990, 2016), expand = c(0, 0)) +
    scale_color_viridis(discrete = T) +
    ggtitle("Per capita income over time") +
    theme_bw() +
    theme(
      panel.border = element_blank(), axis.line = element_line(),
      legend.title = element_blank(), legend.position = "bottom",
      plot.margin = margin(t = 5, r = 12, b = 0, l = 5, unit = "pt")
    )
  ggsave("output/gpd_pc_plot.pdf", plot = gdp_pc_plot, height = 4, width = 6)

  gdp_us_plot <- ggplot(macro_dat_plot, aes(x = year, y = comp_usa, color = country)) +
    geom_line() + xlab("Year") + ylab("US GDP p.c. / GDP p.c. (PPP)") +
    ggtitle("Per capita income in comparison to the USA") +
    scale_x_continuous(limits = c(1990, 2016), expand = c(0, 0)) +
    scale_color_viridis(discrete = T) +
    theme_bw() +
    theme(
      panel.border = element_blank(), axis.line = element_line(),
      legend.title = element_blank(), legend.position = "bottom",
      plot.margin = margin(t = 5, r = 12, b = 0, l = 5, unit = "pt")
    )
  ggsave("output/gpd_usa_comp.pdf", plot = gdp_us_plot, height = 4, width = 6)
}


# Create the export matrix from slide 29 ----
dat_exp_matrix <- dat[, export_rca := ifelse(export_rca > 1, 1, 0)]
dat_exp_matrix <- dat_exp_matrix[, rca_plot := as.character(export_rca)]
dat_exp_matrix <- dat_exp_matrix[is.na(rca_plot) == FALSE]
dat_exp_matrix <- dat_exp_matrix[, k_c_0 := sum(export_rca, na.rm = T), by = location_code]
dat_exp_matrix <- dat_exp_matrix[, k_p_0 := sum(export_rca, na.rm = T), by = product_id]

if (make_plots == T) {
  exp_map <- ggplot(dat_exp_matrix) +
    geom_tile(aes(
      x = reorder(product_id, -k_p_0),
      y = reorder(location_code, -k_c_0),
      fill = rca_plot
    )) +
    scale_fill_viridis(discrete = T) +
    xlab("Products") + ylab("Countries") +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      legend.position = "none",
      legend.title = element_blank()
    )
  exp_map
  ggsave(paste0("output/exp_matrix_", as.character(expl_year), ".pdf"), width = 12, height = 4)
}


# Compare k_0 and k_1 (slide 31) -----

location_activity_matrix <- get.matrix(dat_exp_matrix[, .(location_code, product_id, export_rca)]) # get the location - activity matrix

k_c_0 <- MORc(location_activity_matrix, RCA = TRUE, steps = 0)
k_c_1 <- MORc(location_activity_matrix, RCA = TRUE, steps = 1)
k_c_01_frame <- data.frame(country = names(k_c_0), k.c.0 = k_c_0, k.c.1 = k_c_1, row.names = NULL)

k_p_0 <- MORt(location_activity_matrix, RCA = TRUE, steps = 0)
k_p_1 <- MORt(location_activity_matrix, RCA = TRUE, steps = 1)
k_p_01_frame <- data.frame(product = names(k_p_0), k.c.0 = k_p_0, k.c.1 = k_p_1, row.names = NULL)

if (make_plots) {
  k_c_01_plot <- ggplot(
    k_c_01_frame,
    aes(x = k.c.0, y = k.c.1)
  ) +
    geom_point(alpha = 0.75) +
    geom_smooth(method = "lm", se = T) +
    ggtitle("k_c_0 vs. k_c_1") +
    theme_bw() +
    theme(
      panel.border = element_blank(),
      axis.line = element_line()
    )
  k_c_01_plot

  k_p_01_plot <- ggplot(
    k_p_01_frame,
    aes(x = k.c.0, y = k.c.1)
  ) +
    geom_point(alpha = 0.75) +
    geom_smooth(method = "lm", se = T) +
    ggtitle("k_p_0 vs. k_p_1") +
    theme_bw() +
    theme(
      panel.border = element_blank(),
      axis.line = element_line()
    )
  k_p_01_plot

  k_cp_01_plot <- ggarrange(k_c_01_plot, k_p_01_plot, ncol = 2)

  ggsave(k_cp_01_plot,
    filename = paste0("output/k0_k1_plot_", as.character(expl_year), ".pdf"), height = 4, width = 12
  )
}
