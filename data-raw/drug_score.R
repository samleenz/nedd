## code to prepare `drug_score` dataset goes here

json <- jsonlite::fromJSON("data-raw/structure/singleProtStats.json", simplifyDataFrame = TRUE)

drug_score <- json %>%
  tibble::enframe() %>%
  tidyr::unnest_wider(value) %>%
  dplyr::select(-identity)


usethis::use_data("drug_score")
