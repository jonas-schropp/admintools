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
#' @import xtable
#' @importFrom knitr kable
#' @examples
#' render_invoice(
#'   data = timesheet,
#'   client = filter(addresses, Client == "Client B"),
#'   address = filter(addresses, Client == "talynsight"),
#'   proj_name = "Project 1",
#'   inv_number = "10098",
#'   with = "PI Buck Mulligan, PhD",
#'   discount = "10%"
#'   )


render_invoice <- function(
  data,
  client,
  address,
  proj_name,
  inv_number = 10001,
  with,
  discount,
  VAT = "20%",
  currency = "Euro",
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

  # format addresses
  header <- render_invoice.header(address, client)

  # Put together everything under the detailed table.
  total <- render_invoice.total(
    data = data,
    discount = discount,
    currency = currency,
    VAT = VAT
    )

  # Get name to address the invoice to:
  if (!is.na(client$ref)) {
    to_name <- paste0("Dear ", client$ref, ", \\newline")
  } else if (!is.na(client$organization)) {
    to_name <- paste0("Dear Representatives of the ", client$organization, ", \\newline")
  } else {
    to_name <- paste0("Dear ", client$Client, ", \\newline")
  }

  # Make intro text:
  if (!is.na(proj_name) & !is.na(with)) {
    intro_text <- paste0(
      "My invoice in relation to the project ", proj_name, " with ", with, " amounts to:"
      )
  } else if (!is.na(proj_name) & is.na(with)) {
    intro_text <- paste0(
      "My invoice in relation to the project ", proj_name, " amounts to:"
    )
  } else if (is.na(proj_name) & !is.na(with)) {
    intro_text <- paste0(
      "My invoice in relation to the project with ", with, " amounts to:"
    )
  } else if (is.na(proj_name) & is.na(with)) {
    intro_text <- "For the services detailed below, my invoice amounts to:"
  }

  # Pass on to r markdown
  render(
    input = template,
    params = list(
      data = data,
      to_name = to_name,
      header = header,
      intro_text = intro_text,
      inv_number = inv_number,
      total = total
    ),
    output_file = filename,
    output_dir = dir,
    output_format = "pdf_document",
    encoding = "UTF-8"
  )
}


render_invoice.total <- function(
  data = data,
  discount = discount,
  currency = currency,
  VAT = VAT

) {

  if (currency == "Euro") {
    csym <- "\u20ac"
  }
  # Subtotal = everything above
  Subtotal <- max(data$Total)
  l1 <- paste0("Subtotal: ", Subtotal, " ", csym,"  \n")

  # Apply Discounts
  if(!is.null(discount) & grepl("%", discount)) {
    discountE <- as.double(gsub("%", "", discount))/100*Subtotal
    Subtotal <- Subtotal - discountE
    l2 <- paste0(discount, " discount: -", discountE, " ", csym,"  \n")
    l3 <- paste0("Subtotal: ", Subtotal, " ", csym,"  \n")
  } else if (!is.null(discount) & !grepl("%", discount)){
    Subtotal <- Subtotal - as.double(discount)
    l2 <- paste0("Discount: -", discount, " ", csym,"  \n")
    l3 <- paste0("Subtotal: ", Subtotal, " ", csym,"  \n")
  } else {
    l2 <- NULL
    l3 <- NULL
  }

  # Apply VAT
  if(!is.null(VAT) & grepl("%", VAT)) {
    l4 <- paste0(VAT, " VAT", ": +", as.double(gsub("%", "", VAT))/100*Subtotal, " ", csym,"  \n")
    l5 <- paste0("Total: ", Subtotal + as.double(gsub("%", "", VAT))/100*Subtotal, " ", csym,"  \n")
  } else if (is.null(VAT) | VAT == "Reverse Charge") {
    l4 <- paste0("Total: ", Subtotal, " ", csym,"  \n  \n")
    l5 <- "Reverse Charge Applies."
  }

  # put it all together:
  total <- paste0(l1, l2, l3, l4, l5)
}


render_invoice.header <- function(
    address,
    client
) {
  From <- address %>%
    mutate(
      city = paste0(zip_code, " ", city),
      vat = paste0("VAT-ID: ", vat_id)
    ) %>%
    select(organization, ref, street, city, country, email, phone, vat) %>%
    unlist()

  To <- client %>%
    mutate(
      city = paste0(zip_code, " ", city),
      vat = paste0("VAT-ID: ", vat_id),
      organization = ifelse(is.na(organization), Client, organization)
    ) %>%
    select(organization, street, city, country, email, phone, vat) %>%
    unlist()

  Ref <- client %>%
    mutate(ref = ifelse(is.na(ref), NA, paste0("to: ", ref))) %>%
    select(ref, ref_code, ref_email) %>%
    unlist()

  From <- From[!is.na(From)]
  To <- To[!is.na(To)]
  Ref <- Ref[!is.na(Ref)]

  From <- paste0(From, collapse = " \\newline ")
  To <- paste0(To, collapse = " \\newline ")
  Ref <- paste0(Ref, collapse = " \\newline ")

  c(From, To, Ref)

}

