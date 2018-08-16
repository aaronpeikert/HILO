library(fs)
dir_copy(here("data"), here("data_clean"))

file_delete(here("data_clean", "500109-emotStern2.log"))
file_move(here("data_clean", "500109-emotStern3.log"),
          here("data_clean", "500109-emotStern2.log"))

file_delete(here("data_clean", "500110-emotStern1.log"))
file_move(here("data_clean", "500110-emotStern2.log"),
          here("data_clean", "500110-emotStern1.log"))
file_move(here("data_clean", "500110-emotStern3.log"),
          here("data_clean", "500110-emotStern2.log"))

file_delete(here("data_clean", "500111-emotStern1.log"))
file_move(here("data_clean", "500111-emotStern1 (2).log"),
          here("data_clean", "500111-emotStern1.log"))
file_delete(here("data_clean", "500111-emotStern2.log"))
file_move(here("data_clean", "500111-emotStern2 (2).log"),
          here("data_clean", "500111-emotStern2.log"))
file_delete(here("data_clean", "500111-emotStern3.log"))

file_delete(here("data_clean", "500113-emotStern2.log"))
file_move(here("data_clean", "500113-emotStern3.log"),
          here("data_clean", "500113-emotStern2.log"))

file_delete(here("data_clean", "500123-emotStern2.log"))
file_move(here("data_clean", "500123-emotStern3.log"),
          here("data_clean", "500123-emotStern2.log"))

file_delete(here("data_clean", "500126-emotStern1.log"))
file_move(here("data_clean", "500126-emotStern2.log"),
          here("data_clean", "500126-emotStern1.log"))
file_move(here("data_clean", "500126-emotStern3.log"),
          here("data_clean", "500126-emotStern2.log"))

file_delete(here("data_clean", "500136-emotStern1.log"))
file_move(here("data_clean", "500136-emotStern2.log"),
          here("data_clean", "500136-emotStern1.log"))
file_move(here("data_clean", "500136-emotStern3.log"),
          here("data_clean", "500136-emotStern2.log"))

file_delete(here("data_clean", "500206-emotStern1.log"))
file_move(here("data_clean", "500206-emotStern2.log"),
          here("data_clean", "500206-emotStern1.log"))
file_move(here("data_clean", "500206-emotStern3.log"),
          here("data_clean", "500206-emotStern2.log"))

file_delete(here("data_clean", "500213-emotStern1.log"))
file_move(here("data_clean", "500213-emotStern2.log"),
          here("data_clean", "500213-emotStern1.log"))
file_move(here("data_clean", "500213-emotStern3.log"),
          here("data_clean", "500213-emotStern2.log"))

file_delete(here("data_clean", "500225-emotStern2.log"))
file_move(here("data_clean", "500225-emotStern3.log"),
          here("data_clean", "500225-emotStern2.log"))

file_delete(here("data_clean", "500226-emotStern1.log"))
file_delete(here("data_clean", "500226-emotStern2.log"))
file_move(here("data_clean", "500226-emotStern3.log"),
          here("data_clean", "500226-emotStern1.log"))
file_move(here("data_clean", "500226-emotStern4.log"),
          here("data_clean", "500226-emotStern2.log"))

file_delete(here("data_clean", "500231-emotStern1.log"))
file_move(here("data_clean", "500231-emotStern2.log"),
          here("data_clean", "500231-emotStern1.log"))
file_move(here("data_clean", "500231-emotStern3.log"),
          here("data_clean", "500231-emotStern2.log"))

#500209 & 500230 have three nonempty files