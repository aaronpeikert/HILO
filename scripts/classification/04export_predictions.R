library(here)
source(here("scripts", "classification", "03rpart.R"))

#----export----
predicted <- recipe %>%
  prep(data, retain = TRUE) %>%
  fit_rpart(model = TRUE, minsplit = best_hyper_h$minsplit, minbucket = best_hyper_h$minbucket) %>% 
  predict(prob = TRUE) %>%
  as.data.frame() %>% 
  pull(1)

processed_data <- recipe %>%
  prep(data, retain = TRUE) %>% 
  juice()
dir_create(here("out"))
write_csv(cbind(select(data, ID), predicted, processed_data), here("out", "predictions.csv"))
