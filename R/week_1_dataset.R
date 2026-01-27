
library(tidyverse)


set.seed(123)  # For reproducibility
n <- 200

# =============================================================================
# Step 1: Generate clean baseline data
# =============================================================================

baseline_data <- tibble(
  female_id = 1:n,

  # Treatment: Wolbachia strain or control
  # Wolbachia is an endosymbiotic bacteria that can reduce insect reproduction

  # Age and body mass are correlated (older = larger)
  age_days = sample(20:90, n, replace = TRUE),
  body_mass_mg = rnorm(n, mean = 60 + age_days * 0.3, sd = 12),

  # Site-specific baseline conditions
  site = sample(c("Site_A", "Site_B", "Site_C"), n, replace = TRUE),

  # Collection timing
  collection_date = sample(seq(as.Date("2023-05-01"),
                               as.Date("2023-08-31"),
                               by = "day"),
                           n, replace = TRUE),
  collector = sample(c("Smith", "Jones", "Garcia"), n, replace = TRUE)
) %>%
  mutate(
    # ==========================================================================
    # BIOLOGICAL EFFECTS OF WOLBACHIA TREATMENT
    # ==========================================================================

    # Treatment: Pesticide concentration in egg-laying traps
    treatment = rep(c("Control", "Low_dose", "Medium_dose", "High_dose"),
                    times = n/4),

    # Treatment effects on egg laying (pesticide reduces fecundity)
    treatment_effect = case_when(
      treatment == "Control" ~ 1.0,           # No effect
      str_detect(treatment, "Low") ~ 0.90,    # 10% reduction
      str_detect(treatment, "Medium") ~ 0.75, # 25% reduction
      str_detect(treatment, "High") ~ 0.60,   # 40% reduction
      TRUE ~ 1.0
    ),

    # Pesticides also affect hatching success (toxicity)
    hatching_rate = case_when(
      treatment == "Control" ~ 0.85,          # Normal hatching
      str_detect(treatment, "Low") ~ 0.70,    # Mild toxicity
      str_detect(treatment, "Medium") ~ 0.50, # Moderate toxicity
      str_detect(treatment, "High") ~ 0.30,   # Strong toxicity
      TRUE ~ 0.85
    ),

    # Base egg laying depends on age and body mass
    # Larger, older females lay more eggs
    base_fecundity = pmax(10, 30 + (age_days - 20) * 0.4 + (body_mass_mg - 60) * 0.3),

    # Apply treatment effect
    expected_eggs = base_fecundity * treatment_effect,

    # Actual eggs laid (with biological variation)
    eggs_laid = rpois(n, lambda = expected_eggs),

    # ==========================================================================
    # CYTOPLASMIC INCOMPATIBILITY (CI) - Key Wolbachia effect
    # ==========================================================================
    # When Wolbachia-infected males mate with uninfected females,
    # eggs don't hatch (or hatch at very low rates)
    # This is the mechanism of biological control

    # Eggs hatched (binomial process)
    eggs_hatched = rbinom(n, size = eggs_laid, prob = hatching_rate),

    # For counts of 0, ensure hatched is also 0
    eggs_hatched = pmin(eggs_hatched, eggs_laid)
  ) %>%
  # Clean up intermediate variables
  select(-treatment_effect, -base_fecundity, -expected_eggs, -hatching_rate)

# =============================================================================
# Step 2: Introduce STRING ISSUES (for Tutorial 1)
# =============================================================================

messy_data <- baseline_data %>%
  mutate(
    # Issue 1: Inconsistent capitalization in treatment
    treatment = case_when(
      row_number() %% 7 == 0 ~ str_to_lower(treatment),  # ~21 lowercase
      row_number() %% 11 == 0 ~ str_to_upper(treatment), # ~14 uppercase
      TRUE ~ treatment                                    # Rest normal case
    ),

    # Issue 2: Inconsistent site naming (underscores, spaces, capitalization)
    site = case_when(
      row_number() %% 8 == 0 ~ str_replace(site, "_", " "),  # "Site A"
      row_number() %% 9 == 0 ~ str_to_lower(site),            # "site_a"
      row_number() %% 17 == 0 ~ str_replace(site, "_", "-"),  # "Site-A"
      TRUE ~ site
    ),

    # Issue 3: Collector names with typos and inconsistencies
    collector = case_when(
      collector == "Smith" & row_number() %% 15 == 0 ~ "Smyth",  # Typo
      collector == "Garcia" & row_number() %% 12 == 0 ~ "Garci", # Abbreviated
      collector == "Jones" & row_number() %% 18 == 0 ~ " Jones", # Leading space
      TRUE ~ collector
    )
  )

# =============================================================================
# Step 3: Introduce DATE ISSUES (for Tutorial 2)
# =============================================================================

messy_data <- messy_data %>%
  mutate(
    # Issue 7: Some dates outside study period
    collection_date = if_else(
      row_number() %in% c(45, 112),
      as.Date("2024-01-15"),  # Study ended August 2023
      collection_date
    )
  )

# =============================================================================
# Step 4: Introduce MISSING DATA PATTERNS (for Tutorial 3)
# =============================================================================

messy_data <- messy_data %>%
  mutate(
    # Issue 8: Random missing values (MCAR - Missing Completely At Random)
    body_mass_mg = if_else(
      row_number() %in% sample(1:n, 15),  # ~10% random missing
      NA_real_,
      body_mass_mg
    ),

    # Issue 9: Systematic missing (MAR - related to other variables)
    # Younger females less likely to have egg data (harder to observe)
    eggs_laid = if_else(
      age_days < 30 & runif(n) < 0.4,  # 40% of young females missing
      NA_real_,
      as.numeric(eggs_laid)
    ),
    eggs_hatched = if_else(
      is.na(eggs_laid),
      NA_real_,
      as.numeric(eggs_hatched)
    ),

    # Issue 10: Site B has more missing collector data (equipment/protocol issue)
    collector = if_else(
      site %in% c("Site_B", "site_b", "Site B") & runif(n) < 0.3,
      NA_character_,
      collector
    )
  )

# =============================================================================
# Step 5: Introduce DUPLICATE ISSUES (for Tutorial 4)
# =============================================================================

# Issue 11: Some exact duplicate rows (data entry errors)
duplicate_rows <- messy_data %>%
  slice(sample(1:n, 5))

messy_data <- bind_rows(messy_data, duplicate_rows)

# Shuffle rows so duplicates aren't obvious
messy_data <- messy_data %>% slice(sample(1:nrow(.)))

# =============================================================================
# Step 6: Introduce NUMERIC PLAUSIBILITY ISSUES (for Tutorial 5)
# =============================================================================

messy_data <- messy_data %>%
  mutate(
    # Issue 13: Some negative values (impossible for mass)
    body_mass_mg = if_else(
      row_number() %in% c(15, 78, 134),
      -body_mass_mg,  # 3 negative values
      body_mass_mg
    ),


    # Issue 15: Decimal point errors (e.g., 8.5 instead of 85)
    body_mass_mg = if_else(
      row_number() %in% c(56, 103, 145),
      body_mass_mg / 10,  # 3 values too small by factor of 10
      body_mass_mg
    ),

    # Issue 17: Eggs hatched > eggs laid (biological impossibility)
    eggs_hatched = if_else(
      row_number() %in% c(23, 89, 156),
      eggs_laid + sample(1:10, 3, replace = TRUE),  # More hatched than laid!
      eggs_hatched
    ),

    # Issue 18: Eggs laid = 0 but eggs hatched > 0 (impossible)
    eggs_laid = if_else(
      row_number() %in% c(44, 107),
      0,
      eggs_laid
    )
    # Note: some of these will now have eggs_hatched > 0 when eggs_laid = 0
  )

# =============================================================================
# Step 7: Introduce CROSS-VARIABLE INCONSISTENCIES (for Tutorial 5)
# =============================================================================

messy_data <- messy_data %>%
  mutate(
    # Issue 19: Very young females with high egg production (implausible)
    # In real data, young females shouldn't produce many eggs
    # Create a few more explicit cases
    age_days = if_else(
      row_number() %in% c(12, 76, 138),
      15,  # Very young
      age_days
    ),
    eggs_laid = if_else(
      row_number() %in% c(12, 76, 138),
      70,  # But high egg production (suspicious)
      eggs_laid
    ),

    # Issue 21: Treatment-site combinations that shouldn't exist
    # (e.g., if High treatment was only done at Site_A)
    # Create some impossible combinations
    treatment = if_else(
      row_number() %in% c(18, 63, 119) & site %in% c("Site_B", "site_b", "Site B"),
      "High",  # High treatment at Site B (protocol says this didn't happen)
      treatment
    )
  )

# =============================================================================
# Step 8: Add some METADATA (students should reference this)
# =============================================================================

# Create a README file students can reference
metadata <- "
DATASET METADATA
================

Study: Female insect egg production under different treatment conditions
Period: May 1, 2023 - August 31, 2023
Sites: Three field sites (Site_A, Site_B, Site_C)
Collectors: Smith, Jones, Garcia

Variables:
- female_id: Unique identifier for each female
- treatment: Experimental treatment (Control, Low, Medium, High)
- age_days: Age of female at collection (days since adult emergence)
- body_mass_mg: Body mass in milligrams
- eggs_laid: Total number of eggs laid
- eggs_hatched: Number of eggs that successfully hatched
- collection_date: Date of data collection
- collector: Person who collected the data
- site: Field site where data was collected

Known issues/notes:
- Body mass measurement equipment failed at Site B during June 2023
- Young females (<30 days) are harder to observe, may have more missing data
- High treatment was only administered at Site A (protocol constraint)
- Some individuals were measured multiple times (weekly sampling)
- Normal body mass range for this species: 60-120 mg
- Normal egg production range: 30-70 eggs
- Younger females (<30 days) typically produce fewer eggs (<40)

Collection protocol:
- Females measured weekly when possible
- Mass measured to nearest 0.1 mg
- Eggs counted visually under microscope
- Dates recorded in field notebooks (various formats)
"

# =============================================================================
# Step 9: Save dataset and metadata
# =============================================================================

# Save the messy data
write_csv(messy_data, "data/insect_reproduction_raw.csv")

# Save metadata
writeLines(metadata, "data/metadata.txt")
