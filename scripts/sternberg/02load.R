library(here)
library(tidyverse)
library(readr)

#----load----
whats_here <- function(...)here(..., list.files(here(...)))

logfiles <- tibble(path = whats_here("data", "sternberg_clean"),
                   ocasion = str_extract(path, "\\d.log$") %>%
                     str_remove(".log$") %>% as.numeric())
header <- read_lines(logfiles$path[1], skip = 3, n_max = 1) %>%
  str_split("\t") %>% 
  flatten_chr() %>% 
  tolower() %>% 
  str_replace(" ", "_")

specs <- suppressMessages(spec_tsv(logfiles$path[1], skip = 5, col_names = FALSE))

logfiles <- mutate(
  logfiles,
  file = suppressWarnings(map(
    path,
    read_tsv,
    skip = 5,
    col_names = header,
    col_types = specs
  )),
  file = map(
    file,
    mutate,
    encode = str_detect(code, "^enc\\d*$"),
    probe = str_detect(code, "^probe\\d*$"),
    meta = str_detect(code, "^B_pict\\d*"),
    response = event_type == "Response",
    important = pmap_lgl(list(encode, probe, meta, response), any),
    key = ifelse(encode, "encode", "other"),
    key = ifelse(probe, "probe", key),
    key = ifelse(meta, "meta", key),
    key = ifelse(response, "response", key)
  ),
  file = map(file, filter, important),
  file = map(file, select, subject, code, time, key),
  nrow = map_dbl(file, nrow)
)

logfiles <- filter(logfiles, nrow > 50)

#----normalize-trials----
normalize_trials <- function(file){
  code <- pull(file, "code")
  key <- pull(file, "key")
  #edge1 finding out what encodings and meta belong together
  start <- code[key == "encode"]
  stop <- code[key == "meta"]
  start_nr <- str_extract(start, "\\d*$")
  stop_nr <- str_extract(stop, "^B_pict_\\d*") %>% str_extract("\\d*$")
  if(!isTRUE(all.equal(start_nr, stop_nr))){
    #browser()
    start <- start[start_nr %in% stop_nr]
    stop <- stop[stop_nr %in% start_nr]
  }
  start_pos <- seq_along(start)
  stop_pos <- seq_along(stop)
  for(i in seq_along(start)){
    start_pos[i] <- which(code == start[i])[1]
    stop_pos[i] <- which(code == stop[i])[1]
    code[start_pos[i]] <- NA
    code[stop_pos[i]] <- NA
  }
  #edge1 end
  insert_response <- function(trial){
    if("response" %in% pull(trial, "key")){
      nresponse <- sum("response" == pull(trial, "key"))
      if(nresponse==1)return(trial)
      else{
        #edge4
        #browser()
        time_response <- pull(trial, "time")[pull(trial, "key")=="response"]
        time_response_early <- time_response[time_response<max(time_response)]
        out <- filter(trial, !(time %in% time_response_early))
        return(out)
      }
    }
    else{
      #edge2
      #browser()
      part1 <- filter(trial, key != "meta")
      response <- part1[1,]
      response$time <- NA
      response$code <- NA
      response$key <- "response"
      part2 <- filter(trial, key == "meta")
      out <- rbind(part1, response, part2)
    }
  }
  out <- map2(start_pos, stop_pos, ~(file[seq(.x, .y), ])) #edge1 only select complete trials
  out <- map(out, insert_response)
  out <- imap(out, ~mutate(.x, trial = .y))
  return(out)
}
#normalize_trials <- safely(normalize_trials)

parse_trial <- function(trial){
  time_probe <- (filter(trial, key == "probe") %>% pull("time"))
  time_response <- (filter(trial, key == "response") %>% pull("time"))
  time_passed <- time_response-time_probe
  meta <- filter(trial, key == "meta") %>%
    pull("code")
  probe <-  meta %>% 
    str_extract("probe_[123]_") %>% 
    str_extract("[123]")
  response <- filter(trial, key == "response") %>%
    pull("code")
  probe <- ifelse(probe == "3", 2, probe)
  accurate <- probe == response
  color <- meta %>% str_extract("color_\\d") %>% str_extract("\\d$")
  valence <- meta %>% str_extract("valence_\\d") %>% str_extract("\\d$")
  probenr <- meta %>% str_extract("probe_\\d") %>% str_extract("\\d$")
  subject <- pull(trial, "subject") %>% unique() %>% as.character()
  trial <- pull(trial, "trial") %>% unique()
  out <- tibble(subject, trial, time_passed, accurate, color, valence, probenr)
  return(out)
}
#parse_trial <- safely(parse_trial)
parse_trials <- function(trials)map_dfr(trials, parse_trial)

logfiles <- mutate(logfiles, trials = map(file, normalize_trials),
                   parsed = map(trials, parse_trials))

