library(tidyverse)
library(here)
library(haven)

#----load----
data <- read_sas(here("data", "classification", "var_ap_ii.sas7bdat")) %>% 
  mutate(family = ifelse(family == "", NA, family) %>% factor(),
         ID = as.character(ID),
         group = as.factor(group))
