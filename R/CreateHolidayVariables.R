#' CreateHolidayVariables Create Holiday Count Columns
#'
#' CreateHolidayVariables Rapidly creates holiday count variables based on the date columns you provide
#'
#' @author Adrian Antico
#' @family Feature Engineering
#' @param data This is your data
#' @param DateCols Supply either column names or column numbers of your date columns you want to use for creating calendar variables
#' @param HolidayGroups Pick groups
#' @param Holidays Pick holidays
#' @param GroupingVars Grouping variable names
#' @param Print Set to TRUE to print iteration number to console
#' @import timeDate
#' @examples
#' \dontrun{
#' # Create fake data with a Date----
#' data <- RemixAutoML::FakeDataGenerator(
#'   Correlation = 0.75,
#'   N = 25000L,
#'   ID = 2L,
#'   ZIP = 0L,
#'   FactorCount = 4L,
#'   AddDate = TRUE,
#'   Classification = FALSE,
#'   MultiClass = FALSE)
#' for(i in seq_len(20L)) {
#'   print(i)
#'   data <- data.table::rbindlist(list(data,
#'   RemixAutoML::FakeDataGenerator(
#'     Correlation = 0.75,
#'     N = 25000L,
#'     ID = 2L,
#'     ZIP = 0L,
#'     FactorCount = 4L,
#'     AddDate = TRUE,
#'     Classification = FALSE,
#'     MultiClass = FALSE)))
#' }
#' # Run function and time it
#' runtime <- system.time(
#'   data <- CreateHolidayVariables(
#'     data,
#'     DateCols = "DateTime",
#'     HolidayGroups = c("USPublicHolidays","EasterGroup",
#'       "ChristmasGroup","OtherEcclesticalFeasts"),
#'     Holidays = NULL,
#'     GroupingVars = c("Factor_1","Factor_2","Factor_3","Factor_4"),
#'     Print = FALSE))
#' head(data)
#' print(runtime)
#' }
#' @return Returns your data.table with the added holiday indicator variable
#' @export
CreateHolidayVariables <- function(data,
                                   DateCols = NULL,
                                   HolidayGroups = c("USPublicHolidays","EasterGroup","ChristmasGroup","OtherEcclesticalFeasts"),
                                   Holidays = NULL,
                                   GroupingVars = NULL,
                                   Print = FALSE) {

  # Turn on full speed ahead----
  data.table::setDTthreads(threads = max(1L, parallel::detectCores()-2L))

  # Convert to data.table----
  if(!data.table::is.data.table(data)) data.table::setDT(data)

  # If GroupVars are numeric, convert them to character
  for(zz in seq_along(GroupingVars)) {
    if(is.numeric(data[[eval(GroupingVars[zz])]]) | is.integer(data[[eval(GroupingVars[zz])]])) {
      data.table::set(data, j = GroupingVars[zz], value = as.character(data[[eval(GroupingVars[zz])]]))
    }
  }

  # Require namespace----
  requireNamespace("timeDate", quietly = TRUE)

  # Function for expanding dates, vectorize----
  HolidayCountsInRange <- function(Start, End, Values) return(as.integer(length(which(x = Values %in% seq(as.Date(Start), as.Date(End), by = "days")))))

  # Sort by group and date----
  if(!is.null(GroupingVars)) {
    if(!any(class(data[[eval(DateCols)]]) %chin% c("POSIXct","POSIXt","Date"))) data[, eval(DateCols) := as.POSIXct(data[[eval(DateCols)]])]
    data <- data[order(get(GroupingVars),get(DateCols))]
  }

  # Store individual holidays if HolidayGroups is specified----
  Holidays <- NULL
  if(!is.null(HolidayGroups)) {
    for(counter in seq_len(length(HolidayGroups))) {
      if(tolower(HolidayGroups[counter]) == "eastergroup") {
        Holidays <- c(Holidays,"Septuagesima","Quinquagesima","PalmSunday","GoodFriday","EasterSunday","Easter","EasterMonday","RogationSunday",
                      "Ascension","Pentecost","PentecostMonday","TrinitySunday","CorpusChristi","AshWednesday")
      }
      if(tolower(HolidayGroups[counter]) == "christmasgroup") {
        Holidays <- c(Holidays,"ChristTheKing","Advent1st","Advent1st","Advent3rd","Advent4th","ChristmasEve","ChristmasDay","BoxingDay","NewYearsDay")
      }
      if(tolower(HolidayGroups[counter]) == "otherecclesticalfeasts") {
        Holidays <- c(Holidays,"SolemnityOfMary","Epiphany","PresentationOfLord",
                      "Annunciation","TransfigurationOfLord","AssumptionOfMary",
                      "AssumptionOfMary","BirthOfVirginMary","CelebrationOfHolyCross",
                      "MassOfArchangels","AllSaints","AllSouls")
      }
      if(tolower(HolidayGroups[counter]) == "uspublicholidays") {
        Holidays <- c(Holidays,"USNewYearsDay","USInaugurationDay","USMLKingsBirthday","USLincolnsBirthday","USWashingtonsBirthday","USCPulaskisBirthday","USGoodFriday",
                      "USMemorialDay","USIndependenceDay","USLaborDay","USColumbusDay","USElectionDay","USVeteransDay","USThanksgivingDay","USChristmasDay")
      }
    }
  }

  # Turn DateCols into character names if not already----
  for(i in DateCols) if(!is.character(DateCols[i])) DateCols[i] <- names(data)[DateCols[i]]

  # Allocate data.table cols----
  data.table::alloc.col(DT = data, ncol(data) + 1L)

  # Create Temp Date Columns----
  MinDate <- data[, min(get(DateCols[1L]))]
  if(!is.null(GroupingVars)) {
    for(i in seq_len(length(DateCols))) {
      data.table::setorderv(x = data, cols = c(eval(GroupingVars), eval(DateCols[i])), order = 1L, na.last = TRUE)
      data[, paste0("Lag1_", eval(DateCols[i])) := data.table::shift(x = get(DateCols[i]), n = 1L, fill = MinDate, type = "lag"),  by = c(eval(GroupingVars))]
    }
  } else {
    for(i in seq_len(length(DateCols))) {
      data.table::setorderv(x = data, cols = eval(DateCols[i]), order = 1L, na.last = TRUE)
      data.table::set(data, j = paste0("Lag1_", eval(DateCols[i])), value = data.table::shift(x = data[[eval(DateCols[i])]], n = 1L, fill = MinDate, type = "lag"))
    }
  }

  # Run holiday function to get unique dates----
  library(timeDate)

  # Compute----
  for(i in seq_len(length(DateCols))) {
    x <- data[, quantile(x = (data[[eval(DateCols[i])]] - data[[(paste0("Lag1_",eval(DateCols[i])))]]), probs = 0.99)]
    data[, eval(paste0("Lag1_", DateCols[i])) := get(DateCols[i]) - x]
    HolidayVals <- unique(as.Date(timeDate::holiday(year = unique(lubridate::year(data[[eval(DateCols)]])), Holiday = Holidays)))
    data.table::setkeyv(x = data, cols = c(eval(GroupingVars), DateCols[i], paste0("Lag1_", eval(DateCols[i]))))
    data.table::set(data, i = which(data[[eval(DateCols[i])]] == MinDate), j = eval(paste0("Lag1_",DateCols[i])), value = MinDate - x)
    temp <- unique(data[, .SD, .SDcols = c(DateCols[i], paste0("Lag1_", eval(DateCols[i])))])
    temp[, HolidayCounts := 0L]
    NumRows <- as.integer(seq_len(temp[,.N]))
    for(Rows in NumRows) {
      if(Print) print(Rows)
      data.table::set(x = temp, i = Rows, j = "HolidayCounts", value = sum(HolidayCountsInRange(Start = temp[[paste0("Lag1_", DateCols[1L])]][[Rows]], End = temp[[eval(DateCols)]][[Rows]], Values = HolidayVals)))
    }
    data[temp, on = c(eval(DateCols[i]), paste0("Lag1_", DateCols[i])), HolidayCounts := i.HolidayCounts]
    if(length(DateCols) > 1L) data.table::setnames(data, "HolidayCounts", paste0(DateCols[i], "_HolidayCounts"))
    data.table::set(data, j = eval(paste0("Lag1_", DateCols[i])), value = NULL)
  }

  # Return data----
  return(data)
}
