#' Fictive Address book.
#'
#' Containing my address and the addresses of some fictive clients.
#' as an example how an address book to be used with this package could/should be organized.
#'
#' @title addresses
#' @docType data
#' @format A data frame with 10 rows and 13 variables:
#' \describe{
#'   \item{Client}{Name or identification of the client. Should be the same as 'Client' in timesheet.}
#'   \item{street}{Street & house number.}
#'   \item{city}{City}
#'   \item{zip_code}{Zip code}
#'   \item{country}{Country}
#'   \item{email}{E-mail address of the client.}
#'   \item{phone}{Phone number of the client.}
#'   \item{vat_id}{VAT id if available}
#'   \item{organization}{'Client' can be used as a short identifier, here goes the complete name of the organization you're working with.}
#'   \item{ref}{Name of the reference person if there is one.}
#'   \item{ref_code}{Reference code if there is one.}
#'   \item{ref_email}{Does the reference person have their own email?}
#'   \item{VAT}{Either 'Reverse Charge' or a Percentage.}
#'}
#'
#' @source home made
#' @keywords data
#' @usage data(addresses)
"addresses"
