# Overview
# For each customer and subscription, I want to know the following:
#   What other subscriptions overlapped?
#   How long did they overlap?
#   Note that I only know when they last paid for the subscription.

library(dplyr)
library(lubridate)
library(tidyr)
library(purrr)

subscriptions <- tribble(
  ~customer_id, ~subscription_id, ~payment_date,
  101, "1", as.Date("2019-05-22"),
  101, "1", as.Date("2019-06-23"),
  101, "2", as.Date("2019-07-04"),
  101, "2", as.Date("2019-08-07"),
  102, "1", as.Date("2019-03-11"),
  102, "2", as.Date("2019-04-09"),
  102, "1", as.Date("2019-05-13"),
  102, "2", as.Date("2019-05-11"),
  102, "2", as.Date("2019-06-10"),
  103, "2", as.Date("2019-03-05"),
  103, "1", as.Date("2019-03-10"),
  103, "1", as.Date("2019-04-17"),
  103, "2", as.Date("2019-04-22"),
  103, "3", as.Date("2019-04-30"),
  103, "1", as.Date("2019-05-04"),
  103, "2", as.Date("2019-06-12"),
  103, "3", as.Date("2019-07-12")
)

find_start_and_end <- function(payment_df) {
  
  payment_df %>%
    arrange() %>%
    summarise(start = slice_head(.) %>% pull(), end = slice_tail(.) %>% pull())

}

calc_overlaps <- function(interval_df) {
  
  subs <- interval_df$subscription_id
  
  overlap_df <- map_dfr(subs, function(x){
    compare <- interval_df %>%
      filter(subscription_id == x) %>%
      pull(subscription_duration)
    interval_df %>%
      filter(subscription_id != x) %>%
      mutate(
        overlap = intersect(subscription_duration, compare
          )
        ) %>%
      transmute(subscription_id = x,
        overlaps_with = subscription_id, 
        overlap_duration = overlap %>% as.duration()) 
  }) 
  overlap_df
}

subscriptions %>% 
  group_by(customer_id, subscription_id) %>%
  nest() %>%
  mutate(data  = map(data, find_start_and_end)) %>%
  unnest(cols = c(data)) %>%
  mutate(subscription_duration = interval(start, end)) %>%
  ungroup() %>%
  nest(data = -customer_id) %>%
  mutate(overlaps = map(data, calc_overlaps)) %>%
  select(-data) %>%
  unnest(overlaps)
