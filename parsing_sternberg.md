---
title: "Parsing Sternberg Task"
author: "Aaron"
date: "10/4/2018"
output: pdf_document
---

# Generell Process

The scripts in `scripts/sternberg` are intended to parse the raw files, yielding a tidy dataset, without any manual (or direct) intervention. The first script `01clean_files.R` will the files from `data/sternberg` to `data/sternberg_clean`, and then rename and delete files which were not properly named or were only non-valid sessions were recorded (which resulted, if possible, in a rerecording). In `01load.R` all the heavy lifting (parsing the files) is done. Shape then presents the data in a rectangualr format, and a aggregeation for each person to calc retest reliability.

# Clean Files

In clean files mainly two problems are solved:

1. Invalid filenames, somteimes wile recording a file was accidently not named correctly and the naming scheme was changed after the first few participants.
2. Invalid Recordings are handled, sometimes a session was aborted early and then redone. If there were only a handful of recordings this session was discarded (deleted) and the remaining sessions of that person were renamed accordingly.

This procedure was done based on information from notes of test supervisor.

The commands in the script to delete a file is `file_delete` followed by a r command (`here`) that returns the absolute file path, from a relative path (meaning relaative to the project repository). Renaming is done with `file_move`, with the old filename first followed by the new one (also utilizing the `here`command).

# Load Files

The raw files are unsuitible for any meaningfull dataanalysis. Even though the are in there core a standard plaintext format (tab as delimiter), informations about a single trial are spread over dozens rows. Most of these rows are irrelevant, only four different "types" contained relevant information:

* encoding, these lines indicate the start of a trial, the allways start with "enc" followed by the trialnumber. They are identified with the regular expression `"^enc\\d*$"`.
* probe, the participant is asked to remember, these lines allways start with "probe" followed by the trialnumber. They are identified with the regular expression `"^probe\\d*$`.
* response, these lines contain the "answer" of the participants, they are identified via the `event_type` column with `"Response"`.
* meta, these lines contain meta information about the present trial, they allways start with "B_pict" followed by the trialnumber. They are identified with the regular expression `"^B_pict\\d*"`. They indicate the proper end of a trial.

If a row doesn't match one of the above patterns it is discarded.

If a file has less then 50 (relevant) rows it is discarded. 

## Normalazing (handling edge cases)

1. Trial starts, but no end (meta/B_pict is missing)  
While normalzing all trials where no macthing meta to the encoding (or the other way arround) is found, are silently discarded. This normaly happens when the session was apporded early. Some technical issues seem to result also in the presens of a meta without encoding.
2. Trial starts and end without response (response is missing)  
If there is no response whatsoever this line is inserted and the response is set to `NA` (Not availible).
3. Response accurs before probe
In such case the particpant cannot know the answer, but since the trial is still in proper (normal)form, nothing is done. Subsequently they are in the parsing the are calculated negatively and finaly in the `03shape.R` script the response is set to `NA`.
4. Multiple Responses
In such cases the only the last response is considered, the other are dropped. This includes cases that fall under 3.

Above edge cases or there respective handling in the code are marked with the comment `#edge1`, `#edge2`, ...

## Parsing

In the parsing the now normalized trials, with now exact four rows each are aggregated to one new row with the following columns:

`subject`: subject identifier from the raw log file (not from the filename, but from the column `subject` inside the file)

`trial`: is the trialnumber, from all lines which are identified to be in one trial. Would result in an error when some lines in a trial where different numbers.

`passed_time`: is calculated by subtracting time of response from probe. This can yield negative `passed_time`.

`accurate`: Internally the meta is searched for the pattern `probe_[123]_`, meaning anything that does match `probe1`, `probe2` or `probe3`, then the number is extracted. For `1` only response `1` is correct, for `2` & `3` only response `2` is correct. Therefore `2` & `3` are set to `2` and then result is compared wether or not it is identical to response. Yielding `TRUE`, `FALSE` or `NA`.

`color`: Meta is searched for `"color_\\d"`", then number is extracted.
`valence`: Meta is searched for `"valence_\\d"`", then number is extracted.
`probenr`: Meta is searched for `"probe_\\d"`", then number is extracted.

# Shape

The above steps result in a `tibble` (special form of a `data.frame`) named logfile. This logfile contains following columns:

`path`: the path to a single logfile
`ocasion`: is it the first or second (or in some cases third) measurement occasion, as retrieved from the path/filename number
`file`: containes the rectangular part of the plain logfile, with the unnasacary rows according to [Load Files] removed. Formaly this is a list of data.frames.
`nrow`: how many row file has (equals in most cases four times the number of trials)
`trials`: a list of a list of dataframes, so for every person a list of data.frames where every data.frame represents one trial. After normalazing this data.frame for each trial has exactly four rows.
`parsed`: a list of data.frames each data.frame represents one file, each row one aggregated trial. The columns are the ones which ate described under [Parsing]

This dataframe is obviosly deeply nested and while a very tidy representation for the parsiong unsuitible for dataanalyses because non-rectangular. However making it rectangular is straightforward. Just binding all parsed data.frames together and create a new variable for the occasion.

In the resulting data.frmae (`rect`) the reponses of edgecase 3 are set to NA, and a change in the Subjectnumber is performed. For the retest-dataset, the `rect` data.frame is groubed by occasion and subject and then the mean of accuracy (without NA's) is calculated. Then it is spread into a wide format with one column for each occasion with the mean accuracy. Since the column for the occasion 3 is allmost only filled with NA's, its dropped.

