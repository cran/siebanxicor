validaFecha <- function(fechaString) {
  res <- try(as.Date(fechaString, format = "%Y-%m-%d"))
  if(class(res) == "try-error" || is.na(res))
    stop("Incorrect date format. The submitted date format is incorrect. It must be yyyy-mm-dd.")
}
