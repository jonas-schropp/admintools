#' Renders and invoice
#' By default using the template contained in the package
#'
#' @param data A data.frame containing project data as returned by report_single
#' @param clientlist A data.frame containing names & contact information for your clients
#' @param proj_name Name of the project you want to write the invoice for. One of either proj_name or client_name is required.
#' @param client_name Name of the client you want to write the invoice for.  One of either proj_name or client_name is required.
#' @param template Two templates are provided: "organization.Rmd" for organizational clients and "individual.Rmd" for individuals. If these don't meet your needs you can point to your own template.
#' @return A formatted invoice.
#' @export
#' @import dplyr
#' @import assertthat
#' @import rmarkdown
#' @import here
#' @importFrom knitr kable
#' @examples
#' render_invoice(data = tb, client = data.frame(name = "Universität Bern"), address = data.frame(), proj_name = "FIMADIA", inv_number = "10001", pi = "Naomi", discount = "10%)


render_invoice <- function(
  data,
  client,
  address,
  proj_name,
  inv_number,
  with,
  discount,
  VAT = "20%",
  template = system.file("inst/rmarkdown/templates/invoice/skeleton", "skeleton.Rmd", package = "admintools"),
  filename = paste0(Sys.Date(), "-SENDER-RECIPIENT-NUMBER.pdf"),
  dir = "C:/Users/jonas/Documents/testinvoices",
  verbose = FALSE
) {


  assert_that(
    is.data.frame(data),
    msg = "Error: Data must be of type data.frame."
  )

  assert_that(
    is.data.frame(client),
    msg = "Error: Client must be of type data.frame."
  )

  assert_that(
    is.data.frame(address),
    msg = "Error: Address must be of type data.frame."
  )

  render(
    input = template,
    params = list(
      data = data,
      client = client,
      address = address,
      proj_name = proj_name,
      inv_number = 10001,
      with = with,
      discount = discount,
      VAT = VAT
    ),
    output_file = filename,
    output_dir = dir,
    output_format = "pdf_document",
    encoding = "UTF-8"
  )



}
