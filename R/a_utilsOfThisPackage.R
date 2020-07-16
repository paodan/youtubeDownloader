
# [!+] Convert string into Windows compatible filename
makeFilenames <- function(s, replacement = "_", allow.space = TRUE){
  replacement <- as.character(replacement)

  # Check if `replacement` is an allowed symbol:
  if (grepl(replacement, '\\\\/\\:\\*\\?\\"\\<\\>\\|') == TRUE | nchar(replacement)!=1)
  {
    stop(sprintf("Replacement symbol '%s' is not allowed.", replacement))
  }

  # Do the replacement
  s <- gsub('[\\\\/\\:\\*\\?\\"\\<\\>\\|]',replacement,s)
  if (allow.space == FALSE)
    s <- gsub('[[:space:]]',replacement,s)

  # Return result
  return(s)
}
