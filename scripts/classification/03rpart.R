library(rpart)
library(hmeasure)
library(here)
library(rpart.plot)
source(here("scripts", "classification", "02preprocess.R"))

#----rpart-loocv----
fit_rpart <- function(recipe, ...){
  #browser()
  pred <- recipe %>% juice(all_predictors()) %>% names()
  out <- recipe %>% juice(all_outcomes()) %>% names()
  model_formula <- as.formula(paste0(out, " ~ ", paste(pred, collapse = " + ")))
  rpart(model_formula,
        data = juice(recipe, everything(), composition = "data.frame"),
        method = "class",
        ...)
}
hypermat <- as.data.frame(expand.grid(minsplit = 1:20, minbucket = 1:10))

data_cv <- data_cv %>%
  mutate(hypermat = list(hypermat)) %>% 
  unnest(hypermat, .preserve = c(splits, recipes))

data_cv <- mutate(data_cv, rpart_models = pmap(list(recipe = recipes, minsplit = minsplit, minbucket = minbucket), fit_rpart))

pred_rpart <- function(split, recipe, model, ...) {
  mod_data <- bake(
    recipe, 
    newdata = assessment(split),
    all_predictors()
  )
  out <- bake(recipe, newdata = assessment(split), all_outcomes(), composition = "data.frame")
  out$predicted <- predict(model, newdata = mod_data, ...)[[1]]
  names(out)[1] <- "true"
  return(out)
}
data_cv <- mutate(data_cv,
                  predicted_rpart = pmap(list(splits, recipes, rpart_models),
                                          pred_rpart))
data_cv %>%
  group_by(minsplit, minbucket) %>%
  nest() %>%
  pull("data") %>%
  map("predicted_rpart") %>%
  map(bind_rows) %>%
  map(~HMeasure(recode(.x$true, `2` = 0, `1` = 1), .x$predicted)) %>%
  map("metrics") %>%
  map_dbl("H")

data_cv_metrics <- data_cv %>%
  group_by(minsplit, minbucket) %>%
  summarise(predicted = predicted_rpart %>%
              bind_rows() %>%
              list()) %>% 
  mutate(metrics = map(predicted,
                 ~HMeasure(recode(.x$true, `2` = 0, `1` = 1), .x$predicted)) %>%
           map("metrics")) %>% 
  unnest(metrics)
best_hyper_h <- data_cv_metrics %>% filter(H == max(H))
best_hyper_h <- best_hyper_h[1, c("minsplit", "minbucket")]

best_hyper_f <- data_cv_metrics %>% filter(F == max(F))
best_hyper_f <- best_hyper_h[1, c("minsplit", "minbucket")]

#----rpart-full-h----
recipe %>%
  prep(data, retain = TRUE) %>%
  fit_rpart(model = TRUE, minsplit = best_hyper_h$minsplit, minbucket = best_hyper_h$minbucket) %>% 
  rpart.plot::rpart.plot()

#----rpart-full-f----
recipe %>%
  prep(data, retain = TRUE) %>%
  fit_rpart(model = TRUE, minsplit = best_hyper_f$minsplit, minbucket = best_hyper_f$minbucket) %>% 
  rpart.plot::rpart.plot()
