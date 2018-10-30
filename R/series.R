#'
#' Set the query token
#'
#' Set the token required to query series from \href{http://www.banxico.org.mx/SieInternet}{SIE}.
#'
#' This configuration is required prior to any function call pertaining to this package.
#' The \href{https://www.banxico.org.mx/SieAPIRest}{API} used by siebanxicor requires that
#' every request made, be identified by a token. Otherwise the query will be rejected.
#' In order to work properly with this package is necessary to get a token
#' \href{https://www.banxico.org.mx/SieAPIRest/service/v1/token}{here}.
#'
#' Before any request can be made with other functions, the obtained token must be set.
#'
#' @param token A string that corresponds to the query token obtained.
#'
#' @examples
#'
#' # an own token must be obtained
#' token <- "d4b584b43a1413f56e5abdcc0f9e74db112ce9bb2f1580c80cb252f5a18b30a21"
#' setToken(token)
#'
#' @export
setToken <- function(token) {
  setTokenUtil(token)
}



#'
#' Query time series
#'
#' Recovers data of the indicated time series (up to 100)
#' from \href{http://www.banxico.org.mx/SieInternet}{SIE}.
#'
#' The data series are queried throught the \href{https://www.banxico.org.mx/SieAPIRest}{SIE API}.
#' This API requieres that every request is identified by a token. The token can be requested
#' \href{https://www.banxico.org.mx/SieAPIRest/service/v1/token}{here}.
#' Once the query token has been obtained and prior to use any function from this Package,
#' the token must be set in the current query session, using the function \code{\link{setToken}}.
#'
#' To get a data.frame representing one data series use \code{\link{getSerieDataFrame}}.
#'
#' @param series A vector containing idSeries
#' @param startDate A string with "yyyy-MM-dd" format. Defines the
#'        date on which the period of obtained data starts.
#' @param endDate A string with "yyyy-MM-dd" format. Defines the
#'        date on which the period of obtained data concludes.
#' @return A vector containing the data series requested.
#'
#' @examples
#'
#' \dontrun{
#' ## You need a valid token to run the example
#' setToken("token")
#' idSeries <- c("SF43718","SF46410","SF46407")
#' series <- getSeriesData(idSeries, '2016-01-01','2018-07-12')
#'
#' serie <- getSeriesData("SF43718")
#' }
#'
#' @export
getSeriesData <- function(series, startDate = NULL, endDate = NULL) {
  validaToken()
  if(!is.null(startDate)&&!is.null(endDate)){
      validaFecha(startDate)
      validaFecha(endDate)
  }


  numSeries <- length(series)
  if(numSeries>100) stop("Too many series: Maximum 100 series can be consulted.")

  index <- 1
  responseTmp <- vector("list", numSeries)
  numSeriesConsultadas <- 0
  while(numSeriesConsultadas <= numSeries) {
      indexRespuestas <- 1
      indexSuperior <- index+19
      seriesTmp <- series[index:indexSuperior]
      seriesTmp <- seriesTmp[!is.na(seriesTmp)]

      seriesConsultadas <- consultaSeries(seriesTmp, startDate, endDate)

      if(length(seriesConsultadas) == 0){
        numSeriesConsultadas <- numSeriesConsultadas + 20
        next
      }

      indexSuperior <- index+length(seriesConsultadas)-1

      for(indexSerie in index:indexSuperior) {
        responseTmp[[indexSerie]] <- seriesConsultadas[[indexRespuestas]]
        names(responseTmp)[indexSerie] <- names(seriesConsultadas)[indexRespuestas]
        indexRespuestas <- indexRespuestas + 1
      }

      index <- index + length(seriesConsultadas)
      numSeriesConsultadas <- numSeriesConsultadas + 20
  }
  suppressWarnings(responseTmp[!is.na(names(responseTmp))])
}

#'
#' Time series current value
#'
#' Recovers last value of the indicated time series (up to 100)
#' from \href{http://www.banxico.org.mx/SieInternet}{SIE}.
#'
#' This function queries the last value of each series requested. This value corresponds to the last
#' one published by Banco de México.
#'
#' The data series are queried throught the \href{https://www.banxico.org.mx/SieAPIRest}{SIE API}.
#' This API requieres that every request is identified by a token. The token can be requested
#' \href{https://www.banxico.org.mx/SieAPIRest/service/v1/token}{here}.
#' Once the query token has been obtained and prior to use any function from this Package,
#' the token must be set in the current query session, using the function \code{\link{setToken}}.
#'
#'
#' @param series A vector containing idSeries
#' @return A data.frame containing the data series requested.
#'
#' @examples
#'
#' \dontrun{
#' ## You need a valid token to run the example
#' setToken(token)
#' idSeries <- c("SF43718","SF46410","SF46407")
#' seriesDataFrame <- getSeriesCurrentValue(idSeries)
#'
#' serieDataFrame <- getSeriesCurrentValue("SF43718")
#' }
#'
#' @export
getSeriesCurrentValue <- function(series) {
  validaToken()

  numSeries <- length(series)
  if(numSeries>100) stop("Too many series: Maximum 100 series can be consulted.")

  index <- 1
  responseTmp <- NULL
  while(index <= numSeries) {
    indexSuperior <- index+19
    seriesTmp <- series[index:indexSuperior]
    seriesTmp <- seriesTmp[!is.na(seriesTmp)]

    seriesConsultadas <- consultaUltimoDato(seriesTmp)

    index <- index + 20

    if(length(seriesConsultadas) == 0) next

    if(is.null(responseTmp)) responseTmp <- seriesConsultadas
    else responseTmp <- rbind(responseTmp, seriesConsultadas)
  }
  responseTmp
}



#'
#' Query time series metadata
#'
#' Recovers metadata of the indicated time series (up to 100)
#' from \href{http://www.banxico.org.mx/SieInternet}{SIE}.
#'
#' The series metadata are queried throught the \href{https://www.banxico.org.mx/SieAPIRest}{SIE API}.
#' This API requieres that every request is identified by a token. The token can be requested
#' \href{https://www.banxico.org.mx/SieAPIRest/service/v1/token}{here}.
#' Once the query token has been obtained and prior to use any function from this Package,
#' the token must be set in the current query session, using the function \code{\link{setToken}}.
#'
#' The information can be obtained either in English ("en") or Spanish ("es"), defining the parameter locale.
#' By default the metadata are retrieved in English.
#'
#' @param series A vector containing idSeries.
#' @param locale A string defining the language of the metadata. It can be obtained either in
#'        English ("en") or Spanish ("es").
#' @return A data.frame containing the required metadata.
#'
#' @examples
#'
#' \dontrun{
#' ## You need a valid token to run the example
#' setToken(token)
#' series <- getSeriesMetadata(c("SF43718","SF46410","SF46407"))
#'
#' serie <- getSeriesMetadata("SF43718")
#' }
#'
#' @export
getSeriesMetadata <- function(series, locale="en") {
  validaToken()

  if(is.null(locale) || locale != "es") locale <- "en"

  numSeries <- length(series)
  if(numSeries>100) stop("Too many series: Maximum 100 series can be consulted.")

  index <- 1
  responseTmp <- NULL
  while(index <= numSeries) {
    indexSuperior <- index+19
    seriesTmp <- series[index:indexSuperior]
    seriesTmp <- seriesTmp[!is.na(seriesTmp)]

    seriesConsultadas <- consultaMetadatosSeries(seriesTmp, localeCode = locale)

    index <- index + 20

    if(length(seriesConsultadas) == 0) next

    if(is.null(responseTmp)) responseTmp <- seriesConsultadas
    else responseTmp <- rbind(responseTmp, seriesConsultadas)
  }
  responseTmp
}



#'
#' Get a data.frame from an series Vector
#'
#' This is an utility function, it allows to obtain a data.frame from the vector returned by
#' \code{\link{getSeriesData}}.
#'
#'
#' @param series A vector containing data series. This is the vector returned by
#' \code{\link{getSeriesData}}.
#' @param idSerie A string intentifying the series required, it can only be one.
#' @return A data.frame containing the required data series.
#'
#' @examples
#'
#' \dontrun{
#' ## You need a valid token to run the example
#' setToken("token")
#'
#' series <- getSeriesMetadata(c("SF43718","SF46410","SF46407"))
#'
#' serie <- getSerieDataFrame(series, "SF43718")
#' }
#'
#' @export
getSerieDataFrame <- function(series, idSerie) {
  if(is.null(series) || is.null(idSerie)) NA

  serieRow=series[[idSerie]]

  if(is.null(serieRow)) NA

  data.frame(date=serieRow$date, value=serieRow$value)
}


