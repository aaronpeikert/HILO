library(here)
library(fs)
library(haven)
source(here("scripts", "sternberg", "02load.R"))
#----rect----
rect <- logfiles %>%
  mutate(parsed = map2(parsed, ocasion, ~mutate(.x, occasion = .y))) %>%
  pull(parsed) %>%
  bind_rows() %>%
  mutate(occasion = as.factor(occasion),
         accurate = ifelse(time_passed < 0, NA, accurate)) #edge3

#----recode-ids----
rect <- mutate(rect, subject = recode(subject,
                                      `500135` = "550135",
                                      Pilot2 = "500135",
                                      `00227` = "500227"))

#----retest----
retest <- rect %>%
  group_by(subject, occasion) %>%
  summarise(acc = mean(accurate, na.rm = TRUE),time = mean(time_passed, na.rm = TRUE)) %>% 
  unite(acc_time, time, acc) %>% 
  spread(occasion, acc_time) %>% 
  separate(`1`, c("time1", "acc1"), sep = "_") %>% 
  separate(`2`, c("time2", "acc2"), sep = "_") %>% 
  mutate_at(vars(time1:acc2), as.numeric) %>% 
  select(-`3`)

#----write----
dir_create(here("out"))
write_csv(rect, here("out", "long.csv"))
write_sas(rect, here("out", "long.sas7bdat"))

write_csv(retest, here("out", "wide.csv"))
write_sas(retest, here("out", "wide.sas7bdat"))
