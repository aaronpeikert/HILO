library(rpart)
library(hmeasure)
library(here)
source(here("scripts", "classification", "02preprocess.R"))

#----rpart----
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
data_cv <- mutate(data_cv, rpart_models = map(recipes, fit_rpart))

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


