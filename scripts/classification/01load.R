library(tidyverse)
library(here)
library(haven)

#----load----
is_binary <- function(x, enforce_numeric = TRUE){
  if(enforce_numeric&(!is.numeric(x)))return(FALSE)
  else{
    length(unique(x))==2
  }
}
data <- read_sas(here("data", "classification", "var_ap.sas7bdat")) %>% 
  mutate(family = ifelse(family == "", NA, family) %>% as.factor(),
         ID = as.character(ID)) %>% 
  mutate_if(is_binary, as.factor)
