
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gendered

<!-- badges: start -->
<!-- badges: end -->

The goal of `gendered` is to provide functions that can extract various
gendered forms of speech in **German**. Right now it includes the
following forms:

1.  Gendered pair form (i.e. “Studenten und Studentinnen”)
2.  Gendered symbol form (i.e. “StudentInnen”, “Student:innen”,
    "Student\*innen" etc.)
3.  Gender neutral form (i.e. “Studierende”)

## Installation

You can install the development version of `gendered` from GitHub with:

``` r
# install.packages("remotes)
remotes::install_github("vivifabrien/gendered")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(gendered)
## basic example code
```

## Pair form examples

``` r
pair_examples <- data.frame(text = c("Liebe Migranten und Migrantinnen, liebe Arbeiterinnen und Arbeiter.", 
                                   "Es ist wichtig sich speziell für Arbeiterinnen einzusetzen.",
                                   "Die Bürger und Bürgerinnen verlangen mehr.",
                                   "Bin beim Treffen ehemaliger Stipendiaten und Stipendiatinnen!",
                                   "Polen und auch Polinnen verdienen zu wenig.",
                                   "Innenministerium des Bundes"),
                              text_id = 1:6) 

pair_examples %>% 
  gendered_pairs(text)
```

| text                                                                | text\_id | match                            | word1         | word2           |
|:--------------------------------------------------------------------|---------:|:---------------------------------|:--------------|:----------------|
| Liebe Migranten und Migrantinnen, liebe Arbeiterinnen und Arbeiter. |        1 | migranten und migrantinnen       | migranten     | migrantinnen    |
| Liebe Migranten und Migrantinnen, liebe Arbeiterinnen und Arbeiter. |        1 | arbeiterinnen und arbeiter       | arbeiterinnen | arbeiter        |
| Es ist wichtig sich speziell für Arbeiterinnen einzusetzen.         |        2 | NA                               | NA            | NA              |
| Die Bürger und Bürgerinnen verlangen mehr.                          |        3 | burger und burgerinnen           | burger        | burgerinnen     |
| Bin beim Treffen ehemaliger Stipendiaten und Stipendiatinnen!       |        4 | stipendiaten und stipendiatinnen | stipendiaten  | stipendiatinnen |
| Polen und auch Polinnen verdienen zu wenig.                         |        5 | polen und polinnen               | polen         | polinnen        |
| Innenministerium des Bundes                                         |        6 | NA                               | NA            | NA              |

## Gendered symbol forms

``` r
symbol_examples <- data.frame(text = c("Liebe MigrantInnen & ImmigrantInnen.", 
                                   "Es ist wichtig sich speziell für Arbeiterinnen einzusetzen.",
                                   "Die Bürger:innen verlangen mehr.",
                                   "Bin beim Treffen ehemaliger Stipendiaten/innen!",
                                   "Frankfurter/-innen verdienen zu wenig.",
                                   "Innenministerium des Bundes"),
                              text_id = 1:6) 

symbol_examples %>% 
  gendered_symbols(text) 
```

| text                                                        | text\_id | match              |
|:------------------------------------------------------------|---------:|:-------------------|
| Liebe MigrantInnen & ImmigrantInnen.                        |        1 | MigrantInnen       |
| Liebe MigrantInnen & ImmigrantInnen.                        |        1 | ImmigrantInnen     |
| Es ist wichtig sich speziell für Arbeiterinnen einzusetzen. |        2 | NA                 |
| Die Bürger:innen verlangen mehr.                            |        3 | Bürger:innen       |
| Bin beim Treffen ehemaliger Stipendiaten/innen!             |        4 | Stipendiaten/innen |
| Frankfurter/-innen verdienen zu wenig.                      |        5 | Frankfurter/-innen |
| Innenministerium des Bundes                                 |        6 | NA                 |

## Gender neutral forms

``` r
neutral_examples <- data.frame(text = c("Liebe Studierende und Auszubildende.", 
                                   "Es ist wichtig sich für die Arbeitenden einzusetzen.",
                                   "Geflüchtete sind wichtige Mitglieder der Gesellschaft."),
                              text_id = 1:3) 

neutral_forms <- neutral$gendergerechte_alternativen %>%
  paste0("\\b", ., "\\b") %>%
  paste0(collapse = "|")

neutral_examples %>% 
  dplyr::mutate(neutrals = stringr::str_extract_all(text, neutral_forms)) %>%
  tidyr::unnest_longer(neutrals)
```

| text                                                   | text\_id | neutrals      |
|:-------------------------------------------------------|---------:|:--------------|
| Liebe Studierende und Auszubildende.                   |        1 | Studierende   |
| Liebe Studierende und Auszubildende.                   |        1 | Auszubildende |
| Es ist wichtig sich für die Arbeitenden einzusetzen.   |        2 | Arbeitenden   |
| Geflüchtete sind wichtige Mitglieder der Gesellschaft. |        3 | Geflüchtete   |
