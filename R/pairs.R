#' Extract gendered pairs from German text
#'
#' This function extracts gendered pairs from German text based on specified rules.
#'
#' @param text_dat A data frame or tibble containing the text data.
#' @param text The name of the column in `text_dat` that contains the text to be processed.
#' @param debug Logical value indicating whether to include debug information in the output.
#'   If set to TRUE, the output will include intermediate columns such as `clean_text`, `match1`, `match2`, etc.
#'   If set to FALSE (default), the intermediate columns are excluded from the output.
#'
#' @return A modified data frame or tibble with extracted gendered pairs.
#'
#' @export
#'
#' @examples
#' pair_examples <- data.frame(text = c("Liebe Migranten und Migrantinnen, liebe Arbeiterinnen und Arbeiter.",
#' "Verlierer & Verlierinnen der Wirtschaftskrise",
#' "Es ist wichtig sich speziell für Arbeiterinnen einzusetzen.",
#' "Die Bürger und Bürgerinnen verlangen mehr.",
#' "Bin beim Treffen ehemaliger Stipendiaten und Stipendiatinnen!",
#' "Polen und auch Polinnen verdienen zu wenig.",
#' "Innenministerium des Bundes"),
#' text_id = 1:7)
#'
#'
#' # Extract gendered pairs from a text column named "text" in a data frame named "symbol_examples"
#' pair_examples %>% gendered_pairs(text)
#'
#' @importFrom dplyr mutate rowwise ungroup
#' @importFrom stringr str_remove_all str_squish str_extract_all str_to_lower str_replace_all str_starts str_sub str_detect word
#' @importFrom tidyr unchop unnest_longer
gendered_pairs <- function(text_dat, text, debug = FALSE) {
    final_dat <- text_dat %>%
        ## some cleaning of text before we pipe it in
        dplyr::mutate(
            clean_text = stringr::str_remove_all({{ text }}, "-|\\bliebe\\b|\\bdie\\b|\\bden\\b|\\bder\\b|\\bauch\\b|\\bwerte\\b") %>% stringr::str_squish(),
            ## extract word und female plural
            match1 = stringr::str_extract_all(clean_text, "\\w+\\s+(und|&)\\s+\\w+innen"),
            ## extract female plural und word
            match2 = stringr::str_extract_all(clean_text, "\\w+innen\\s+(und|&)\\s+\\w+")
        ) %>%
        ## unnest multiple matches
        tidyr::unchop(match1, keep_empty = TRUE) %>%
        tidyr::unchop(match2, keep_empty = TRUE) %>%
        dplyr::mutate(
            ## clean match1
            match1 = match1 %>%
                stringr::str_to_lower() %>%
                stringr::str_replace_all("ä", "a") %>%
                stringr::str_replace_all("ü", "u") %>%
                stringr::str_replace_all("ö", "o"),
            ## clean match2
            match2 = match2 %>%
                stringr::str_to_lower() %>%
                stringr::str_replace_all("ä", "a") %>%
                stringr::str_replace_all("ü", "u") %>%
                stringr::str_replace_all("ö", "o"),
            ## extract first and last word for female last
            match1_word1 = stringr::word(match1, 1),
            match1_word2 = stringr::word(match1, 3),
            ## extract first and last word for female first
            match2_word1 = stringr::word(match2, 1),
            match2_word2 = stringr::word(match2, 3),
            ## drop if first or second word don't appear in the other
            ## also drop if the first three characters are the same and the
            ## fourth letter is e or i
            to_drop1 = dplyr::case_when(
                stringr::str_starts(match1_word1, stringr::str_sub(match1_word2, end = 3)) &
                    stringr::str_sub(match1_word1, end = 4, start = 4) %in% c("e", "i") ~ FALSE,
                stringr::str_starts(match1_word2, stringr::str_sub(match1_word1, end = 3)) &
                    stringr::str_sub(match1_word2, end = 4, start = 4) %in% c("e", "i") ~ FALSE,
                stringr::str_detect(match1_word1, stringr::str_sub(match1_word2, end = 4)) ~ FALSE,
                stringr::str_detect(match1_word2, stringr::str_sub(match1_word1, end = 4)) ~ FALSE,
                TRUE ~ TRUE
            ),
            to_drop2 = dplyr::case_when(
                stringr::str_starts(match2_word1, stringr::str_sub(match2_word2, end = 3)) &
                    stringr::str_sub(match2_word1, end = 4, start = 4) %in% c("e", "i") ~ FALSE,
                stringr::str_starts(match2_word2, stringr::str_sub(match2_word1, end = 3)) &
                    stringr::str_sub(match2_word2, end = 4, start = 4) %in% c("e", "i") ~ FALSE,
                stringr::str_detect(match2_word1, stringr::str_sub(match2_word2, end = 4)) ~ FALSE,
                stringr::str_detect(match2_word2, stringr::str_sub(match2_word1, end = 4)) ~ FALSE,
                TRUE ~ TRUE
            ),
            ## drop if both matches are bad
            to_drop3 = ifelse(to_drop1 & to_drop2, TRUE, FALSE)
        ) %>%
        ## final match
        dplyr::rowwise() %>%
        dplyr::mutate(
            match = dplyr::case_when(
                !to_drop1 & !to_drop2 ~ list(c(match1, match2)),
                to_drop1 & !to_drop3 ~ list(match2),
                to_drop2 & !to_drop3 ~ list(match1),
                TRUE ~ list(NA_character_)
            )
        ) %>%
        dplyr::ungroup() %>%
        tidyr::unnest_longer(match)

    if (!debug) {
        final_dat <- final_dat %>%
            dplyr::mutate(
                word1 = stringr::word(match, 1),
                word2 = stringr::word(match, 3)
            ) %>%
            dplyr::select(-clean_text:-to_drop3)
    }

    return(final_dat)
}
