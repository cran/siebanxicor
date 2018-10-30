

EndPointSeries <- "https://www.banxico.org.mx/SieAPIRest/service/v1/series/"

localEnv <- new.env(parent = emptyenv())
localEnv$BmxToken <- "NA"

validaToken <- function() {
  if(localEnv$BmxToken=="NA") stop("A token must be set prior to query series. Use setToken(token)")
}


setTokenUtil <- function(token) {
  if(!is.na(token) && !is.null(token))
    localEnv$BmxToken <- token
}



consultaSeries <- function(seriesArr, startDate = NULL, endDate = NULL) {
  if(length(seriesArr)>20) stop("Too many series, can only request maximun 20")

  url <- EndPointSeries
  path <- "/datos/"
  locale <- "?locale=en"
  fechas <- ""
  series <- paste(seriesArr, sep = ",", collapse = ",")

  if(!is.null(startDate) && !is.null(endDate))
      fechas <- paste(startDate, endDate, sep = "/")

  request <- paste(url, series, path, fechas, locale, sep = "")
  token <- localEnv$BmxToken
  headers <- httr::add_headers("Bmx-Token" = token, "Accept" = "application/json")

  response <- httr::GET(request, headers)

  if(response$status_code==200) {

    jSonResponse=httr::content(response, as = "text")
    bmxObject <- jsonlite::fromJSON(jSonResponse)
    series <- bmxObject$bmx$series

    seriesResponse <- vector("list", nrow(series))

    for (row in 1:nrow(series)) {
        idSerieTmp <- series[row, "idSerie"]
        datos <- series[row, "datos"]

        if(is.null(datos) || is.null(datos[[1]])) next

        datosConvertidos <- suppressWarnings(as.numeric(gsub(",", "", datos[[1]][  ,"dato"], fixed = TRUE)))
        fechasConvertidas <- as.Date(datos[[1]][  ,"fecha"], "%d/%m/%Y")
        datosDataFrame <- data.frame(date=fechasConvertidas, value=datosConvertidos)

        seriesResponse[[row]] <- c(datosDataFrame)
        names(seriesResponse)[row] <- idSerieTmp
    }
    suppressWarnings(seriesResponse[!is.na(names(seriesResponse))])
  } else if(response$status_code==404) {
    warning(paste("Serie not found: ", series))
  } else {
    jSonResponse=httr::content(response, as = "text")
    bmxObject <- jsonlite::fromJSON(jSonResponse)
    mensaje <- bmxObject$error$mensaje
    detalle <- bmxObject$error$detalle

    stop(paste(mensaje,": ",detalle))
  }
}





consultaMetadatosSeries <- function(seriesArr, localeCode="en") {
  if(length(seriesArr)>20) stop("Too many series, can only request maximun 20")

  url <- EndPointSeries
  locale <- "?locale="
  series <- paste(seriesArr, sep = ",", collapse = ",")

  request <- paste(url, series, locale, localeCode, sep = "")
  token <- localEnv$BmxToken
  headers <- httr::add_headers("Bmx-Token" = token, "Accept" = "application/json")

  response <- httr::GET(request, headers)

  if(response$status_code==200) {

    jSonResponse=httr::content(response, as = "text")
    bmxObject <- jsonlite::fromJSON(jSonResponse)
    series <- bmxObject$bmx$series

    seriesResponse <- NULL

    formatoFecha <- "%m/%d/%Y"
    if(localeCode == "es") formatoFecha <- "%d/%m/%Y"

    for (row in 1:nrow(series)) {
      idSerieTmp <- series[row, "idSerie"]
      tituloSerieTmp <- series[row, "titulo"]
      fechaInicioTmp <- series[row, "fechaInicio"]
      fechaFinTmp <- series[row, "fechaFin"]
      periodicidadTmp <- series[row, "periodicidad"]
      cifraTmp <- series[row, "cifra"]
      unidadTmp <- series[row, "unidad"]

      serieDataFrame <- data.frame(idSerie=idSerieTmp,
                                   title=tituloSerieTmp,
                                   startDate=as.Date(fechaInicioTmp, formatoFecha),
                                   endDate=as.Date(fechaFinTmp, formatoFecha),
                                   frequency=periodicidadTmp,
                                   dataType=cifraTmp,
                                   unit=unidadTmp
                                   )

      if(is.null(seriesResponse)) seriesResponse=serieDataFrame
      else seriesResponse <- rbind(seriesResponse, serieDataFrame)
    }
    seriesResponse
  } else if(response$status_code==404) {
    warning(paste("Serie not found: ", series))
  } else {
    jSonResponse=httr::content(response, as = "text")
    bmxObject <- jsonlite::fromJSON(jSonResponse)
    mensaje <- bmxObject$error$mensaje
    detalle <- bmxObject$error$detalle

    stop(paste(mensaje,": ",detalle))
  }
}





consultaUltimoDato <- function(seriesArr) {
    if(length(seriesArr)>20) stop("Too many series, can only request maximun 20")

    url <- EndPointSeries
    path <- "/datos/oportuno"
    locale <- "?locale=en"
    series <- paste(seriesArr, sep = ",", collapse = ",")

    request <- paste(url, series, path, locale, sep = "")
    token <- localEnv$BmxToken
    headers <- httr::add_headers("Bmx-Token" = token, "Accept" = "application/json")

    response <- httr::GET(request, headers)

    if(response$status_code==200) {

      jSonResponse=httr::content(response, as = "text")
      bmxObject <- jsonlite::fromJSON(jSonResponse)
      series <- bmxObject$bmx$series

      seriesResponse <- NULL

      for (row in 1:nrow(series)) {
        idSerieTmp <- series[row, "idSerie"]
        datos <- series[row, "datos"]

        if(is.null(datos) || is.null(datos[[1]])) next

        datosConvertidos <- suppressWarnings(as.numeric(gsub(",", "", datos[[1]][  ,"dato"], fixed = TRUE)))
        fechasConvertidas <- as.Date(datos[[1]][  ,"fecha"], "%d/%m/%Y")
        serieDataFrame <- data.frame(idSerie=idSerieTmp, date=fechasConvertidas[[1]], value=datosConvertidos[[1]])

        if(is.null(seriesResponse)) seriesResponse=serieDataFrame
        else seriesResponse <- rbind(seriesResponse, serieDataFrame)
      }
      suppressWarnings(seriesResponse[!is.na(names(seriesResponse))])
    } else if(response$status_code==404) {
      warning(paste("Serie not found: ", series))
    } else {
      jSonResponse=httr::content(response, as = "text")
      bmxObject <- jsonlite::fromJSON(jSonResponse)
      mensaje <- bmxObject$error$mensaje
      detalle <- bmxObject$error$detalle

      stop(paste(mensaje,": ",detalle))
    }
  }


