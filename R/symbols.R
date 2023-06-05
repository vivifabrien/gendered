#' Extract gendered forms from German text
#'
#' This function extracts gendered forms from German text based on specified rules.
#'
#' @param text_dat A data frame or tibble containing the text data.
#' @param text The name of the column in `text_dat` that contains the text to be processed.
#' @param singular Logical value indicating whether to extract the singular version of gendered forms.
#'   By default, it is set to FALSE, which then only extracts the plural version.
#' @param debug Logical value indicating whether to include debug information in the output.
#'   If set to TRUE, the output will include the `clean_text` column with squished text.
#'   If set to FALSE (default), the `clean_text` column is excluded from the output.
#'
#' @return A modified data frame or tibble with extracted gendered forms.
#'
#' @export
#'
#' @examples
#' symbol_examples <- data.frame(text = c("Liebe MigrantInnen & ImmigrantInnen.",
#' "Es ist wichtig sich speziell für Arbeiterinnen einzusetzen.",
#' "Die Bürger:innen verlangen mehr.",
#' "Bin beim Treffen ehemaliger Stipendiaten/innen!",
#' "Frankfurter/-innen verdienen zu wenig.",
#' "Innenministerium des Bundes"),
#' text_id = 1:6)
#'
#' # Extract gendered forms from a text column named "text" in a data frame named "symbol_examples"
#' # extract ONLY plural forms
#' symbol_examples %>% gendered_symbols(text)
#' # extract plural AND singular forms
#' symbol_examples %>% gendered_symbols(text, singular = TRUE)
#'
#' @importFrom dplyr mutate select
#' @importFrom stringr str_squish str_extract_all
#' @importFrom tidyr unchop
gendered_symbols <- function(text_dat, text, singular = FALSE, debug = FALSE) {
    regex_term <- if (singular) {"\\S+([:punct:]i|I)(n|nnen)\\b"} else {"\\S+([:punct:]i|I)nnen\\b"}

    final_dat <- text_dat %>%
        dplyr::mutate(
            clean_text = stringr::str_squish({{ text }}),
            match = stringr::str_extract_all(clean_text, regex_term)) %>%
        tidyr::unchop(match, keep_empty = T)

    if (!debug) {
        final_dat <- final_dat %>%
            dplyr::select(-clean_text)
    }

    return(final_dat)
}
