# =============================================================================
# Generate Mayfly Contamination Dataset
# =============================================================================
# Purpose: Create simulated data for binomial GLM workshop
#
# Data structure:
#   - 120 stream sites
#   - Copper contamination gradient (3-157 μg/L, right-skewed)
#   - Dissolved oxygen varies (5-11 mg/L, independent effect)
#   - Mayfly presence follows logistic response to copper AND DO
#   - Sample size per site varies (3-8 samples)
#   - Overdispersion present (beta-binomial variation)
#
# Expected analysis:
#   - Strong negative effect of copper (log-transformed preferred)
#   - Moderate positive effect of DO
#   - No interaction needed
#   - Overdispersion moderate (phi ~ 2-2.5)
#   - LC50 approximately 45-50 μg/L
# =============================================================================

library(tidyverse)

set.seed(2024)

# Sample size
n_sites <- 120

# Generate site-level data
sites <- tibble(
  site_id = paste0("SITE_", str_pad(1:n_sites, 3, pad = "0")),

  # Stream names (some sites share streams - spatial clustering)
  stream_name = sample(
    c("Copper Creek", "Silver Run", "Mining Fork", "Reference Brook",
      "Acid Branch", "Clear Stream", "Contaminated Creek", "Pristine River",
      "Pollution Run", "Clean Fork", "Industrial Stream", "Mountain Brook"),
    size = n_sites,
    replace = TRUE,
    prob = c(0.12, 0.10, 0.08, 0.12, 0.08, 0.10, 0.08, 0.08, 0.08, 0.08, 0.06, 0.02)
  ),

  # Spatial coordinates (for reference, not used in analysis)
  latitude = runif(n_sites, 51.2, 51.8),
  longitude = runif(n_sites, -1.5, -0.8),

  # Sample effort varies by site (3-8 samples per site)
  samples_collected = sample(3:8, size = n_sites, replace = TRUE,
                             prob = c(0.10, 0.15, 0.25, 0.25, 0.15, 0.10)),

  # Copper concentration: right-skewed distribution
  # Most sites low contamination, few very high
  copper_ugl = exp(rnorm(n_sites, mean = log(25), sd = 0.9)),

  # Dissolved oxygen: mostly independent of copper
  # Range 5-11 mg/L (typical for streams)
  # Weak negative correlation with copper (r ~ -0.15)
  do_mgl = 8.5 + rnorm(n_sites, mean = -0.02 * (copper_ugl - 50), sd = 1.2),

  # Temperature: weak positive correlation with copper
  # (contaminated streams may be warmer due to lack of riparian vegetation)
  temperature_c = 13 + rnorm(n_sites, mean = 0.01 * (copper_ugl - 50), sd = 2.5),

  # pH: mostly independent, slight negative correlation with copper
  # (acid mine drainage lowers pH)
  ph = 7.2 + rnorm(n_sites, mean = -0.002 * (copper_ugl - 50), sd = 0.5)
) |>
  # Constrain environmental variables to realistic ranges
  mutate(
    copper_ugl = pmax(3, pmin(copper_ugl, 160)),  # 3-160 μg/L
    do_mgl = pmax(5, pmin(do_mgl, 11.5)),         # 5-11.5 mg/L
    temperature_c = pmax(8, pmin(temperature_c, 19)), # 8-19°C
    ph = pmax(6.0, pmin(ph, 8.5))                  # 6.0-8.5
  )

# Check copper distribution (should be right-skewed)
# hist(sites$copper_ugl, breaks = 30)
# hist(log(sites$copper_ugl), breaks = 30)  # Should look more normal

# Check DO vs copper correlation (should be weak)
# cor(sites$copper_ugl, sites$do_mgl)  # Target ~ -0.10 to -0.20

# =============================================================================
# Generate mayfly presence data
# =============================================================================
#
# Logistic model for probability of mayfly in a single sample:
#   logit(p) = β0 + β1*log(copper) + β2*DO
#
# Parameters chosen to give:
#   - High probability (~0.9) at low copper (10 μg/L) and high DO (10 mg/L)
#   - Low probability (~0.1) at high copper (100 μg/L) and low DO (6 mg/L)
#   - LC50 around 45-50 μg/L at average DO
#   - DO effect meaningful but secondary to copper
#
# Then add overdispersion via beta-binomial variation

# Model parameters
beta_0 <- 3.5       # Intercept
beta_copper <- -1.2 # Coefficient for log(copper) - strong negative effect
beta_do <- 0.4      # Coefficient for DO - moderate positive effect

# Calculate linear predictor (log-odds)
sites <- sites |>
  mutate(
    # Mean log-odds of mayfly presence per sample
    log_odds_mean = beta_0 +
      beta_copper * log(copper_ugl) +
      beta_do * (do_mgl - 8),  # Center DO at 8 mg/L

    # Convert to probability
    p_mean = plogis(log_odds_mean),  # plogis = inverse logit = 1/(1+exp(-x))

    # Add overdispersion: beta-binomial variation
    # This creates extra-binomial variation in p across samples at same site
    # Dispersion parameter theta controls how much variation
    # (smaller theta = more overdispersion)
    theta = 3,  # This will create phi ~ 2-2.5 in final GLM

    # Draw site-specific probability from beta distribution
    # parameterised by mean and dispersion
    shape1 = p_mean * theta,
    shape2 = (1 - p_mean) * theta,
    p_site = rbeta(n(), shape1, shape2),

    # Constrain to (0.01, 0.99) to avoid perfect separation
    p_site = pmax(0.01, pmin(p_site, 0.99))
  )

# Generate binomial outcomes
sites <- sites |>
  mutate(
    # Number of samples containing mayflies
    samples_with_mayfly = rbinom(n(), size = samples_collected, prob = p_site),

    # Total mayfly individuals (if present)
    # This is for potential extension analyses - not used in main binomial GLM
    # Generate from negative binomial conditional on presence
    total_mayflies = map2_int(
      samples_with_mayfly,
      p_site,
      function(n_pos, p) {
        if (n_pos == 0) return(0)
        # When present, abundance follows negative binomial
        # Higher probability = more abundant (weak correlation)
        mu <- n_pos * 3 * p  # Mean abundance
        rnbinom(1, size = 2, mu = mu)
      }
    )
  )

# Clean up intermediate columns
mayfly_data <- sites |>
  dplyr::select(
    site_id,
    stream_name,
    latitude,
    longitude,
    samples_collected,
    samples_with_mayfly,
    total_mayflies,
    copper_ugl,
    do_mgl,
    temperature_c,
    ph
  ) |>
  # Round to realistic precision
  mutate(
    copper_ugl = round(copper_ugl, 1),
    do_mgl = round(do_mgl, 1),
    temperature_c = round(temperature_c, 1),
    ph = round(ph, 1),
    latitude = round(latitude, 4),
    longitude = round(longitude, 4)
  )

# =============================================================================
# Validation checks
# =============================================================================

# Summary statistics
mayfly_data |>
  summarise(
    n_sites = n(),
    # Response variable
    mean_prop_with_mayfly = mean(samples_with_mayfly / samples_collected),
    sites_never = sum(samples_with_mayfly == 0),
    sites_always = sum(samples_with_mayfly == samples_collected),
    sites_sometimes = sum(samples_with_mayfly > 0 &
                            samples_with_mayfly < samples_collected),
    # Predictors
    copper_median = median(copper_ugl),
    copper_range = paste0(round(min(copper_ugl), 1), "-",
                          round(max(copper_ugl), 1)),
    do_median = median(do_mgl),
    do_range = paste0(round(min(do_mgl), 1), "-",
                      round(max(do_mgl), 1))
  )

# Expected overdispersion check
# Fit quick model to verify overdispersion is present
test_model <- glm(
  cbind(samples_with_mayfly, samples_collected - samples_with_mayfly) ~
    log(copper_ugl) + do_mgl,
  family = binomial,
  data = mayfly_data
)

dispersion_check <- test_model$deviance / test_model$df.residual
cat("\nExpected overdispersion parameter:", round(dispersion_check, 2), "\n")
cat("Target range: 2.0-2.5\n")

# Correlation check
cor_matrix <- mayfly_data |>
  dplyr::select(copper_ugl, do_mgl, temperature_c, ph) |>
  cor() |>
  round(2)

cat("\nPredictor correlations:\n")
print(cor_matrix)
cat("\nTarget: copper-DO correlation should be weak (-0.1 to -0.2)\n")

# Visual check: Does relationship look sensible?
mayfly_data |>
  mutate(prop_mayfly = samples_with_mayfly / samples_collected) |>
  ggplot(aes(x = copper_ugl, y = prop_mayfly)) +
  geom_point(aes(size = samples_collected), alpha = 0.5) +
  geom_smooth(method = "loess", colour = "blue") +
  scale_size_continuous(range = c(2, 8)) +
  labs(
    x = "Copper concentration (μg/L)",
    y = "Proportion of samples with mayflies",
    size = "Samples\ncollected",
    title = "Mayfly occurrence vs copper contamination",
    subtitle = "Expected pattern: Smooth decline from high to low probability"
  ) +
  theme_minimal()

# Expected LC50 calculation
coefs <- coef(test_model)
lc50_expected <- exp(-(coefs[1] + coefs[3] * (8 - 8)) / coefs[2])  # At DO = 8
cat("\nExpected LC50 (at DO = 8 mg/L):", round(lc50_expected, 1), "μg/L\n")
cat("Target range: 45-55 μg/L\n")

# =============================================================================
# Write data
# =============================================================================

write_csv(mayfly_data, "mayfly_contamination.csv")

cat("\n=== Dataset generation complete ===\n")
cat("File: mayfly_contamination.csv\n")
cat("Sample size:", nrow(mayfly_data), "sites\n")
cat("\nExpected student findings:\n")
cat("- Strong negative effect of copper (log-transformed preferred)\n")
cat("- Moderate positive effect of dissolved oxygen\n")
cat("- No interaction needed\n")
cat("- Overdispersion present (phi ~", round(dispersion_check, 2), ")\n")
cat("- Quasibinomial model appropriate\n")
cat("- LC50 approximately", round(lc50_expected, 0), "μg/L\n")

# =============================================================================
# Optional: Generate figure showing "true" relationship for instructor reference
# =============================================================================

# Predictions across copper gradient at different DO levels
pred_grid <- expand_grid(
  copper_ugl = seq(5, 150, by = 1),
  do_mgl = c(6, 8, 10)  # Low, medium, high DO
) |>
  mutate(
    log_odds = beta_0 + beta_copper * log(copper_ugl) + beta_do * (do_mgl - 8),
    probability = plogis(log_odds)
  )

ggplot() +
  # Raw data
  geom_point(
    data = mayfly_data |>
      mutate(prop_mayfly = samples_with_mayfly / samples_collected),
    aes(x = copper_ugl, y = prop_mayfly, size = samples_collected),
    alpha = 0.3
  ) +
  # True relationship at different DO levels
  geom_line(
    data = pred_grid,
    aes(x = copper_ugl, y = probability, colour = factor(do_mgl)),
    linewidth = 1
  ) +
  scale_colour_manual(
    values = c("6" = "red", "8" = "blue", "10" = "green"),
    labels = c("6" = "6 mg/L (low)", "8" = "8 mg/L (medium)", "10" = "10 mg/L (high)"),
    name = "Dissolved oxygen"
  ) +
  scale_size_continuous(range = c(1, 6), guide = "none") +
  labs(
    x = "Copper concentration (μg/L)",
    y = "Probability of mayfly presence",
    title = "True underlying relationship (for instructor reference)",
    subtitle = "Student models should approximate these curves"
  ) +
  theme_minimal() +
  theme(legend.position = c(0.75, 0.75),
        legend.background = element_rect(fill = "white", colour = "grey50"))
