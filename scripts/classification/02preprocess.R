library(here)
library(recipes)
library(rsample)
source(here("scripts", "classification", "01load.R"))

#----preprocess----
recipe <- tidyselect::vars_select(names(data), -ID, -group) %>%
  paste(collapse = " + ") %>%
  paste("group", "~", .) %>% 
  as.formula() %>% 
  recipe(data) %>% 
  step_modeimpute(family) %>% 
  step_dummy(family) %>% 
  step_meanimpute(all_predictors()) %>% 
  step_center(all_predictors()) %>% 
  step_scale(all_predictors())

data_cv <- loo_cv(data)

data_cv <- mutate(data_cv, recipes = map(splits,
                                         prepper,
                                         recipe = recipe,
                                         retain = TRUE,
                                         verbose = FALSE))  
  