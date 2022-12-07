#' Check colnames of imported file
#'
#' @param filename Filename (and path) of dataset to import
#' @param sheetname Sheetname
#' @param skiprows Number of rows to skip
#' @param oldnames Variable names to change
#' @param newnames New variable names
#'
#' @return Message if colnames of imported file match 'oldnames' and a dataframe
#' containing the colnames of the imported file, 'oldnames' and 'newnames'.
#' @export
check_colnames <- function(filename,
                           sheetname,
                           skiprows,
                           oldnames,
                           newnames){
  df <- suppressMessages(readxl::read_excel(filename,
                                            sheet = sheetname,
                                            skip = skiprows,
                                            n_max = 1))

  same_names <- all(colnames(df) == oldnames)

  if(same_names == TRUE) message("You're good: colnames of imported file are equivalent to 'oldnames.'")
  if(same_names == FALSE) message("Not good: colnames of imported file do not match 'oldnames'. Compare colnames_import and oldnames to see mismatches. Also check that newnames corresponds to the correct oldnames.")
  df_print <- data.frame(colnames_import = colnames(df), oldnames = oldnames, newnames = newnames)
  return(df_print)
}
