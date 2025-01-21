# Visualize mean and standard error using ggplot2
library(ggplot2)

# Biased data===

set.seed(123)

# Simulate population data with equal representation of groups A, B, and C
population_data <- data.frame(
  Group = rep(c("Location 1", "Location 2", "Location 3"), each = 1000),
  Values = c(rnorm(1000, mean = 50, sd = 10),  # Group A
             rnorm(1000, mean = 60, sd = 10),  # Group B
             rnorm(1000, mean = 70, sd = 10))  # Group C
)

# Simulate biased sample with underrepresentation of Group C
biased_sample_data <- data.frame(
  Group = c(rep("Location 1", 200), rep("Location 2", 200), rep("Location 3", 25)),
  Values = c(rnorm(200, mean = 50, sd = 10),  # Group A
             rnorm(200, mean = 60, sd = 10),  # Group B
             rnorm(25, mean = 70, sd = 10))  # Group C
)

bias_sum <- biased_sample_data |>
  summarise(mean = mean(Values),
            sd = sd(Values))

population_data |>
  group_by(Group) |>
  summarise(mean = mean(Values),
            sd = sd(Values))

pop_sum <- population_data |>
  summarise(mean = mean(Values),
            sd = sd(Values))


# Combine for comparison
stats_comparison <- rbind(
  data.frame(Type = "Population", pop_sum),
  data.frame(Type = "Biased Sample", bias_sum)
)



ggplot(stats_comparison, aes(x = Type, y = mean, fill = Type)) +
  geom_bar(stat = "identity", width = 0.6) +
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.2) +
  ggtitle("Comparison of Mean and Standard Error: Population vs. Biased Sample") +
  ylab("Mean Value") +
  theme_minimal()+
  theme(legend.position = "none")




# Simulate temperature data over 365 days (1 year)
days <- 1:365
temperature <- rnorm(365, mean = 15, sd = 10)  # Mean temperature 15°C, with some variability

# Simulate some extreme weather conditions (very low or very high temperatures)
temperature[c(50:60, 200:210)] <- c(rnorm(11, mean = -5, sd = 3), rnorm(11, mean = 40, sd = 3))  # Extreme cold and hot days

# Create a data frame for the simulation
weather_data <- data.frame(Day = days, Temperature_Missing = temperature)

# Introduce missing data: simulate the buoy cutting out when temperature is below 0°C or above 35°C
weather_data$Temperature <- ifelse(weather_data$Temperature_Missing < 0 | weather_data$Temperature_Missing > 35, NA, weather_data$Temperature)
weather_data$Colour <- ifelse(weather_data$Temperature_Missing < 0 | weather_data$Temperature_Missing > 35, "darkred", "blue")
weather_data <- weather_data |>
  pivot_longer(cols = Temperature:Temperature_Missing, names_to = "Record", values_to = "Temperature_Celsius") |>
  mutate(Record = fct_relevel(Record, "Temperature_Missing"))



weather_data |>
  filter(Record == "Temperature_Missing") |>
ggplot(aes(x = Day,
           y = Temperature_Celsius)) +
  geom_line(aes(colour = Colour,
                alpha = Colour,
                group = 1))+
  ggtitle("Temperature Data with and without Missing Data") +
  ylab("Temperature (°C)") +
  geom_smooth(method = "loess",
              se = FALSE,
              colour = "darkred")+
  geom_smooth(data = weather_data |> filter(Record == "Temperature"),
              method = "loess",
              se = FALSE,
              colour = "blue")+
  scale_colour_identity()+
  scale_alpha_manual(values = c(.4, .8))+
  theme(legend.position = "none")


  ## Survivorship Bias

  img.file <- here::here("images", "ww-2-plane.png")
  img <- png::readPNG(img.file)

  x <- c(rep(.38, 10), rep(.5, 10), rep(.61, 10), rep(.5, 30))
  y <- c(rep(.8, 10), rep(.8, 10), rep(.8, 10), rep(.2, 10), rep(.3, 10), rep(.4, 10))

  plane_data <- tibble(x,y)

  # Create a ggplot object with the image as a background
  ggplot(plane_data) +
    ggpubr::background_image(img)+
    # Add bullet holes using geom_point (these represent areas where surviving planes had damage)
    geom_jitter(aes(x = x,
                   y = y),
               width = .025,
               height = .05,
               color = "black", size = 2) +
    # Set x and y axis limits to fit the image and points properly
    xlim(0, 1) +
    ylim(0, 1) +
    # Add a title to the plot
    ggtitle("Survivorship Bias: Bullet Holes on WW2 Planes") +
    theme_minimal() +
    theme(panel.grid = element_blank(),
          panel.border = element_blank(),
          axis.title = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank())

  # Outlier bias


  # Step 1: Generate a simple linear dataset
  set.seed(123)
  n <- 100
  x <- rnorm(n, mean = 50, sd = 10)
  y <- 2 * x + rnorm(n, mean = 0, sd = 5)  # y = 2x + noise
  data <- data.frame(x = x, y = y)

  # Step 2: Add outliers to the dataset
  outliers_x <- c(70, 60, 50)
  outliers_y <- c(240, 245, 250)  # Extreme values, significantly higher than expected trend
  outliers <- data.frame(x = outliers_x, y = outliers_y)

  # Combine the original data with outliers
  data_with_outliers <- rbind(data, outliers)

  linetype <- c("Data with outliers" = "solid", "Data without outliers" = "dotdash")

  # Step 3: Plot the data without outliers and show the regression line
  p1 <- ggplot(data, aes(x = x, y = y)) +
    geom_point(color = "blue",
               size = 2,
               alpha = .1) +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    ggtitle("Data Without Outliers") +
    theme_minimal()+
    scale_x_continuous(limits = c(0,110))+
    scale_y_continuous(limits = c(50, 250))

  # Step 4: Plot the data with outliers and show how the regression line changes
  p2 <- ggplot(data_with_outliers, aes(x = x, y = y)) +
    geom_point(color = "blue",
               size = 2,
               alpha = .1) +
    geom_point(data = outliers, aes(x = x, y = y),
               color = "red",
               size = 3
               ) +
    geom_smooth(aes(linetype = "Data with outliers"), method = "lm", se = FALSE, color = "black") +
    geom_smooth(data = data, method = "lm", se = FALSE, color = "black",
                aes(linetype = "Data without outliers")) +
    ggtitle("Data With Outliers (Red Points)") +
    theme_minimal()+
    scale_x_continuous(limits = c(0,110))+
    scale_y_continuous(limits = c(50, 250))+
    scale_linetype_manual(values = linetype)

  # Combine the two plots side by side
  library(patchwork)
  p1+p2


  # Omitted variable bias

  # Load necessary library
  library(ggplot2)

  # Step 1: Simulate data
  set.seed(123)

  # Step 1: Simulate data
  set.seed(123)

  n <- 200
  gender <- sample(c("Male", "Female"), n, replace = TRUE)  # Randomly assign gender

  # Generate 'before' and 'after' drug intervention data
  # Assume before intervention, both men and women have similar health measures
  before_intervention <- if_else(gender == "Female",
                                 rnorm(n, mean = 40, sd = 10),  # Women improve by ~5 units
                                 rnorm(n, mean = 50, sd = 10))  # Men show no improvement


  # After intervention: Drug works for women (increase) but not for men
  after_intervention <- if_else(gender == "Female",
                               before_intervention + rnorm(n, mean = 10, sd = .5),  # Women improve by ~5 units
                               before_intervention + rnorm(n, mean = 0, sd = .5))  # Men show no improvement

  # Combine into a data frame
  drug_data <- data.frame(Gender = gender, Before = before_intervention, After = after_intervention) |>
    pivot_longer(cols = Before:After,
                 names_to = "Intervention",
                 values_to = "Effect") |>
    mutate(Intervention = fct_relevel(Intervention, "Before"))

  drug_data |>
    ggplot(aes(x = Intervention,
               y = Effect))+
    geom_boxplot()+
    geom_jitter(width = .2)

  drug_data |>
    ggplot(aes(x = Intervention,
               y = Effect,
               colour = Gender))+
    geom_boxplot()+
    geom_point(position = position_jitterdodge(dodge.width = .8,
                                               jitter.width = .2))

  p1 +p2


  ## Impossible outliers====

  # Load necessary libraries
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  # Set seed for reproducibility
  set.seed(123)

  # Step 1: Generate plausible data (e.g., heights in cm, with normal distribution)
  n <- 300
  heights <- rnorm(n, mean = 170, sd = 10)  # Normal human height range (in cm)

  # Step 2: Add implausible outliers (e.g., extremely tall people but plausible)
  implausible_heights <- c(220, 225, 230)  # Plausible but extreme values (very tall people)

  # Step 3: Add impossible outliers (e.g., negative height or extremely large values)
  impossible_heights <- -30  # Impossible values

  # Combine all data
  all_heights <- data.frame(Height = c(heights, implausible_heights, impossible_heights),
                            Type = c(rep("Plausible", n),
                                     rep("Implausible", length(implausible_heights)),
                                     rep("Impossible", length(impossible_heights))))
   # Step 4: Create a density plot with raincloud points
  ggplot(all_heights, aes(x = Height, y = 1)) +
    # Density plot
    ggridges::geom_density_ridges(alpha = 0.4, fill = "cyan", colour = "darkgrey") +

    # Add points (raincloud-style) for each group
#    geom_point(aes( color = Type), size = 3, alpha = 0.7, height = 0.02, width = 0.05) +

    ggdist::stat_dots(aes(fill = Type),
                      colour = "white",
                      # put dots underneath
                      side = "bottom",
                      # move position down
                      justification = 1,
                      # size of dots
                      dotsize = 3,

                      # adjust bins (grouping) of dots
                     binwidth = 1
              )+

    # Vertical line for a plausible range (for reference, e.g., human heights)
    geom_vline(xintercept = c(140, 200), linetype = "dashed", color = "black") +

    # Title and theme adjustments
    ggtitle("Density Plot with Raincloud Points: Plausible, Implausible, and Impossible Outliers") +
    scale_color_manual(values = c("Plausible" = "cyan", "Implausible" = "darkorange", "Impossible" = "purple")) +
    scale_fill_manual(values = c("Plausible" = "cyan", "Implausible" = "darkorange", "Impossible" = "purple")) +
    theme_minimal() +
    theme(legend.position = "top")+
    coord_cartesian(ylim = c(.98,1.09))
   # scale_y_continuous(limits = c(.5,1.2))
