#' Fictive Timesheet.
#'
#' The data set contains information on work carried out during three months
#' as an example how a timesheet to be used with this package could/should look.
#'
#' @title timesheet
#' @docType data
#' @format A data frame with 80 rows and 7 variables:
#' \describe{
#'   \item{Date}{Date when work was carried out}
#'   \item{Client}{Name or identification of the client. Should be the same as 'Client' in addresses.}
#'   \item{Project}{Name of the Project the work is related to.}
#'   \item{With}{The name of the PI or team lead of the project if there is one.}
#'   \item{Task}{The category of work that was carried out.}
#'   \item{Description}{A more detailed description.}
#'   \item{Hours}{How many hours you worked.}
#'   \item{Hourly}{The hourly compensation in whatever currency you use.}
#'   \item{Compensation}{Hours*Hourly}
#'}
#'
#' @source home made
#' @keywords data
"timesheet"
