#' @export
gendered_symbols <- function(text_dat, text, singular = FALSE, debug = FALSE) {
    regex_term <- if (singular) {"\\S+([:punct:]i|I)(n|nnen)\\b"} else {"\\S+([:punct:]i|I)nnen\\b"}
    
    final_dat <- text_dat %>%
        dplyr::mutate(
            clean_text = stringr::str_squish({{ text }}),
            match = stringr::str_extract_all(clean_text, regex_term)) %>%
        tidyr::unchop(match, keep_empty = T) 

    if(!debug){
        final_dat <- final_dat %>%
            dplyr::select(-clean_text)
    }

    return(final_dat)
}
