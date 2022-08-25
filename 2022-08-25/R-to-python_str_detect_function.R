# create_folder_from_date <- function (path, file=NULL, date=NULL) {
#   
#   if(is.null(date)) {
#     date <- Sys.Date() %>%
#       
#   }
#   date <- Sys.Date()
#   fs::dir_create()
#   
# }

library(dplyr)
library(readr)
library(readxl)
library(stringr)

## function to detect and extract possible monkey pox related calls: pass in a tibble (df) as the argument
monkey_pox_detect <- function(df) {
  
  ## implement some control flow
  # - if argument is missing: break out of function and tell user "break" is really a print() execution
  # - else move on to next flow structure
  # - if the argument passed in not a tibble/df object, tell user invalid argument passed
  # - else execute the piped operations
  # - str_detect() on col(A2, A8, A9, A10, A11) to detect instance of monkey pox mentioned
  # - group by date then aggregate
  
  if (missing(df)) {
    print("No argument passed into the function.")
  } else {
    if (!is_tibble(df)) {
      print("Invalid argument type passed.")
    } else {
      df = df %>%
        mutate(mp_detect1 = case_when(
          str_detect(A2, pattern = "monkeypox status: monkeypox related") ~ "YES",
          TRUE ~ "NO"),
          mp_detect2 = case_when(
            str_detect(A9, pattern = "monkey pox|pox|mpx|monkey|monkeypox") ~ "YES",
            TRUE ~ "NO"),
          mp_detect3 = case_when(
            str_detect(A10, pattern = "monkey pox|pox|mpx|monkey|monkeypox") ~ "YES",
            TRUE ~ "NO"),
          mp_detect4 = case_when(
            str_detect(A11, pattern = "monkey pox|pox|mpx|monkey|monkeypox") ~ "YES",
            TRUE ~ "NO")) %>%
        filter(mp_detect1 == "YES" | mp_detect2 == "YES" | mp_detect3 == "YES" | mp_detect4 == "YES") %>%
        group_by(date) %>%
        summarize(calls = n()) %>%
        print()
      
      return(df)
    }
  }
}

df <- readxl::read_xlsx("sample_data.xlsx")