#' @export
gendered_pairs <- function(text_dat, text, debug = F) {
    final_dat <- text_dat %>%
        ## we need a text id, maybe drop later
        # mutate(text_id = 1:n()) %>%
        ## some cleaning of text before we pipe it in
        dplyr::mutate(clean_text = stringr::str_remove_all({{ text }}, "-|\\bliebe\\b|\\bdie\\b|\\bden\\b|\\bder\\b|\\bauch\\b|\\bwerte\\b") %>% stringr::str_squish(),
                      ## extract word und female plural
                      match1 = stringr::str_extract_all(clean_text, "\\w+\\s+(und|&)\\s+\\w+innen"),
                      ## extractfemale plural und word
                      match2 = stringr::str_extract_all(clean_text, "\\w+innen\\s+(und|&)\\s+\\w+")
        ) %>%
        ## unnest multiple matches
        tidyr::unnest_longer(match1) %>%
        tidyr::unnest_longer(match2) %>%
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
                    stringr::str_sub(match1_word1, end = 4, start = 4)  %in% c("e", "i") ~ F,
                stringr::str_starts(match1_word2, stringr::str_sub(match1_word1, end = 3)) &
                    stringr::str_sub(match1_word2, end = 4, start = 4)  %in% c("e", "i") ~ F,
                stringr::str_detect(match1_word1, stringr::str_sub(match1_word2, end = 4)) ~ F,
                stringr::str_detect(match1_word2, stringr::str_sub(match1_word1, end = 4)) ~ F,
                T ~ T),
            to_drop2 = dplyr::case_when(
                stringr:: str_starts(match2_word1, stringr::str_sub(match2_word2, end = 3)) &
                    stringr::str_sub(match2_word1, end = 4, start = 4)  %in% c("e", "i") ~ F,
                stringr::str_starts(match2_word2, stringr::str_sub(match2_word1, end = 3)) &
                    stringr::str_sub(match2_word2, end = 4, start = 4)  %in% c("e", "i") ~ F,
                stringr::str_detect(match2_word1, stringr::str_sub(match2_word2, end = 4)) ~ F,
                stringr::str_detect(match2_word2, stringr::str_sub(match2_word1, end = 4)) ~ F,
                T ~ T),
            ## drop if both matches are bad
            to_drop3 = ifelse(to_drop1 & to_drop2, T, F)) %>%
        ## final match
        dplyr::rowwise() %>%
        dplyr::mutate(
            match = dplyr::case_when(
                !to_drop1 & !to_drop2 ~ list(c(match1, match2)),
                to_drop1 & !to_drop3 ~ list(match2),
                to_drop2 & !to_drop3 ~list(match1),
                T ~ list(NA_character_)
            )) %>%
        dplyr::ungroup() %>%
        tidyr::unnest_longer(match)

    if(!debug){
        final_dat <- final_dat %>%
            dplyr::mutate(
                word1 = stringr::word(match, 1),
                word2 = stringr::word(match, 3)) %>%
            dplyr::select(-clean_text:-to_drop3)
    }

    return(final_dat)
}


