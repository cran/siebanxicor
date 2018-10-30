#'
#' Economic information of Banco de México
#'
#' This package is aimed at querying data series from Banco de México.
#'
#' siebanxicor allows to retrieve the time series of all indicators available in
#' \href{http://www.banxico.org.mx/SieInternet}{SIE}.
#' This tool aims at developers and analysts who seek to make automatic the retrieval
#' of the economic information published by Banco de México.
#'
#' This package uses the \href{https://www.banxico.org.mx/SieAPIRest}{SIE API} to obtain
#' the data series published.
#' This API requires that every request be identified by a token. This query token can
#' be obtained \href{https://www.banxico.org.mx/SieAPIRest/service/v1/token}{here}.
#' The query token can be used in multiple requests, as long as the query limits are respected
#' (\href{https://www.banxico.org.mx/SieAPIRest/service/v1/doc/limiteConsultas}{more information}).
#'
#'
#' To start using the functions included in this package, is mandatory first to set the token
#' using \code{\link{setToken}}:
#'
#' \preformatted{
#' token <- "d4b584b43a1413f56e5abdcc0f9e74db112ce9bb2f1580c80cb252f5a18b30a21"
#' setToken(token)
#' }
#'
#'
#' The string token is only an example, an own token must be generated in the aforementioned link.
#'
#' Once the token has been set, the data series can be retrieved using \code{\link{getSeriesData}}:
#'
#' \preformatted{
#' idSeries <- c("SF43718","SF46410","SF46407")
#' series <- getSeriesData(idSeries)
#' }
#'
#' The time period retrieved can be limited using the parameters \code{startDate} and \code{endDate}.
#' These parameters are strings that represent a date in the format "yyyy-MM-dd".
#' If one of these dates is omitted the entire data are returned.
#'
#' \preformatted{
#' idSeries <- c("SF43718","SF46410","SF46407")
#' series <- getSeriesData(idSeries, startDate='2016-01-01',endDate='2018-07-12')
#' }
#'
#' It is also possible to query only the current value of certain time series. The function \code{\link{getSeriesCurrentValue}}
#' accomplishes this task:
#'
#' \preformatted{
#' idSeries <- c("SF43718","SF46410","SF46407")
#' seriesDataFrame <- getSeriesCurrentValue(idSeries)
#'
#' serieDataFrame <- getSeriesCurrentValue("SF43718")
#' }
#'
#' The value returned is the last one published in SIE.
#' \preformatted{
#'
#' }
#'
#' The series metadata can be queried with the function \code{\link{getSeriesMetadata}}:
#'
#' \preformatted{
#' series <- getSeriesMetadata(c("SF43718","SF46410","SF46407"))
#' }
#'
#'
#' The idSeries requiered to use this package can be found in
#' \href{http://www.banxico.org.mx/SieInternet}{SIE} and in the
#' \href{https://www.banxico.org.mx/SieAPIRest/service/v1/doc/catalogoSeries}{"Series catalogue"}
#'
#' @docType package
#' @name siebanxicor
#'
NULL
