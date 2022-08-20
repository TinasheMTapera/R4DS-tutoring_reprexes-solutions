# dplyr & tibble
library(dplyr)
library(tibble)

# we're using iris
head(iris, 20)

# here's what you want to do, no?
iris %>%
  mutate(var1 = case_when(Species == "setosa" ~ "1_hello",
                          Species != "setosa" ~ "2_goodbye")
         ) %>%
  separate
  sample_n(15)

# create a separate lookup table! :)

lookup <- tribble(
  ~Species, ~var1, ~var2,
  "setosa", 1, "hello",
  "versicolor", 2, "goodbye",
  "virginica", 2, "goodbye"
)

left_join(iris, lookup) %>%
  sample_n(15)

# or a function

double_mutate <- function(col) {
  
  output_col1 <- case_when()
}