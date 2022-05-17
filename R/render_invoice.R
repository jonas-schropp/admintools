#' Renders an invoice using either the template contained in the package
#' or one supplied by the user
#'
#' @param data A data.frame containing project data as returned by `report_single`. Required.
#' @param client A data.frame containing names & contact information for your clients Required.
#' @param address A data.frame containing your company address. Required.
#' @param proj_name Name of the project you want to write the invoice for.
#' @param inv_number invoice number. Required.
#' @param with Name of the project leader/manager/principle investigator you worked with.
#' @param discount Either NULL (no discount), a number (interpreted as units of whatever currency you use) or a character containing "\%" (interpreted as a percentage).
#' @param VAT Either NULL, a percentage (formatted as VAT = "XX\%") or "Reverse Charge".
#' @param currency The currency you are using. Euro and Dollar are converted to their respective unicode signs.
#' @param intro You can provide a custom intro sentence, if NULL it will be constructed from proj_name and with.
#' @param template The template `invoice-template` is provided. If it doesn't meet your needs you can point to your own template.
#' @param filename Name of the file to be written.
#' @param dir Path to the directory.
#' @param iban your IBAN. Either IBAN/BIC or SWIFT are required.
#' @param bic your BIC. Either IBAN/BIC or SWIFT are required.
#' @param swift Either IBAN/BIC or SWIFT are required.
#' @param bank Optional, name of your bank.
#' @param timelimit Optional, either NULL or the number of days until the invoice needs to be settled.
#' @return A formatted invoice based on the template and the provided data in pdf format.
#' @export
#' @import dplyr
#' @import assertthat
#' @import rmarkdown
#' @import here
#' @examples
#'timesheet %>%
#'  comp_table(
#'    client_name = "Client A"
#'  ) %>%
#'  render_invoice(
#'    client = filter(addresses, Client == "Client A"),
#'    address = filter(addresses, Client == "talynsight"),
#'    inv_number = "20570",
#'    iban = "DE12345678",
#'    bic = "BLABLA01",
#'    bank = "Parkbank"
#'  )
#'
#' timesheet %>%
#'   comp_table(
#'     client_name = "Client B",
#'     proj_name = "Project 1",
#'     agg_by = "Month",
#'     min_date = as.Date("2022-01-01"),
#'     max_date = as.Date("2022-04-30")
#'   ) %>%
#'   render_invoice(
#'     client = filter(addresses, Client == "Client B"),
#'     address = filter(addresses, Client == "talynsight"),
#'     proj_name = "Project 1",
#'     inv_number = "10098",
#'     iban = "DE12345678",
#'     bic = "BLABLA01",
#'     bank = "Parkbank",
#'     with = "PI Jim Lahey, Trailer Park Supervisor,",
#'     discount = "10%",
#'     filename = paste0(Sys.Date(), "-talynsightOÜ-ClientB-10098.pdf")
#'  )


render_invoice <- function(
  data,
  client,
  address,
  proj_name = NULL,
  inv_number = 10001,
  with = NULL,
  discount = NULL,
  VAT = "20%",
  currency = "Euro",
  iban = NULL,
  bic = NULL,
  swift = NULL,
  bank = NULL,
  intro = NULL,
  timelimit = NULL,
  template = "invoice-template",
  filename = paste0(Sys.Date(), "-SENDER-RECIPIENT-NUMBER"),
  dir = NULL
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

  assert_that(
    !is.null(inv_number),
    msg = "Error: Invoice number can not be empty."
  )

  assert_that(
    !(is.null(iban) & is.null(bic)) | !is.null(swift),
    msg = "Error: Invoice number can not be empty."
  )

  # Get currency symbol for Euro or Dollar
  # Else just use currency name
  if (currency == "Euro") {
    csym <- "\u20ac"
  } else if (currency == "Dollar") {
    csym <- "\u0024"
  } else {
    csym <- currency
  }

  # format addresses
  header <- render_invoice.header(
    address,
    client
    )

  # Put together everything under the detailed table.
  total <- render_invoice.total(
    data = data,
    discount = discount,
    csym = csym,
    VAT = VAT
    )

  # Get name to address the invoice to:
  if (!is.na(client$ref)) {
    to_name <- paste0("Dear ", client$ref, ",  ")
  } else if (!is.na(client$organization)) {
    to_name <- paste0("Dear Representatives of the ", client$organization, ",  ")
  } else {
    to_name <- paste0("Dear ", client$Client, ",  ")
  }

  # Make intro text:
  intro_text <- render_invoice.introtext(
    intro = intro,
    proj_name = proj_name,
    with = with
  )

  # Make main table
  latex_tbl <- render_invoice.latextbl(
    data = data,
    csym = csym
    )

  # banking info
  if (is.null(swift)) {
    acc_no <- paste0(
      address$organization,
      " \\newline IBAN: ",
      iban, " \\newline ",
      "BIC: ", bic, " \\newline "
      )
  } else {
    acc_no <- paste0(
      address$organization,
      " \\newline SWIFT: ",
      swift,
      " \\newline "
      )
  }
  if (!is.null(bank)) {
    acc_no <- paste0(acc_no, "Bank: ", bank, " \\newline")
  }

  # timelimit
  if (!is.null(timelimit)) {
    timelimit <- paste0(" within ", timelimit, " days")
  }

  company <- address$organization
  signer <- address$ref

  if (template == "invoice-template" ) {
    template <- draft(filename, template = "invoice-template", package = "admintools")
  } else {
    template <- draft(filename, template = template)
  }

  filename <- paste0(filename, ".pdf")

  # Pass on to r markdown
  render(
    input = template,
    params = list(
      latex_tbl = latex_tbl,
      to_name = to_name,
      header = header,
      intro_text = intro_text,
      inv_number = inv_number,
      total = total,
      company = company,
      signer = signer,
      timelimit = timelimit,
      acc_no = acc_no
    ),
    output_file = filename,
    output_dir = dir,
    output_format = "pdf_document",
    encoding = "UTF-8"
  )
}



# Convert the part of the invoice under the detailed item table to plain text
render_invoice.total <- function(
  data = data,
  discount = discount,
  csym = csym,
  VAT = VAT

) {

  # Subtotal = everything above
  Subtotal <- max(data$Total)
  l1 <- paste0("Subtotal: ", Subtotal, " ", csym,"  \n")

  # Apply Discounts
  if (is.null(discount)) {
    l2 <- NULL
    l3 <- NULL
  } else if (!is.null(discount) & grepl("%", discount)) {
    discountE <- as.double(gsub("%", "", discount))/100*Subtotal
    Subtotal <- Subtotal - discountE
    l2 <- paste0(discount, " discount: -", discountE, " ", csym,"  \n")
    l3 <- paste0("Subtotal: ", Subtotal, " ", csym,"  \n")
  } else if (!is.null(discount) & !grepl("%", discount)){
    Subtotal <- Subtotal - as.double(discount)
    l2 <- paste0("Discount: -", discount, " ", csym,"  \n")
    l3 <- paste0("Subtotal: ", Subtotal, " ", csym,"  \n")
  }

  # Apply VAT
  if (is.null(VAT)) {
    l4 <- NULL
    l5 <- NULL
    warningCondition(message = "Warning: No VAT applied.")
  } else if(!is.null(VAT) & grepl("%", VAT)) {
    l4 <- paste0(VAT, " VAT", ": +", as.double(gsub("%", "", VAT))/100*Subtotal, " ", csym,"  \n")
    l5 <- paste0("\\textbf{Total: ", Subtotal + as.double(gsub("%", "", VAT))/100*Subtotal, " ", csym,"}  \n")
  } else if (VAT == "Reverse Charge") {
    l4 <- paste0("\\textbf{Total: ", Subtotal, " ", csym,"}  \n  \n")
    l5 <- "Reverse Charge Applies."
  }

  # put it all together:
  total <- paste0(l1, l2, l3, l4, l5)
}


# Convert the addresses (you and client) to latex
# to be used in the header table
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
    mutate(
      organization = paste0("\\textbf{", organization, "}"),
      ref = paste0("\\textbf{", ref, "}")
    ) %>%
    unlist()

  To <- client %>%
    mutate(
      city = paste0(zip_code, " ", city),
      vat = paste0("VAT-ID: ", vat_id),
      organization = ifelse(is.na(organization), Client, organization)
    ) %>%
    select(organization, street, city, country, email, phone, vat) %>%
    mutate(
      organization = paste0("\\textbf{", organization, "}")
    ) %>%
    unlist()

  Ref <- client %>%
    mutate(
      ref = ifelse(is.na(ref), NA, paste0("attn: ", ref)),
      ref_code = ifelse(is.na(ref_code), NA, paste0("ref: ", ref_code)),
      ref_email = ifelse(is.na(ref_email), NA, paste0("e-mail: ", ref_email))
      ) %>%
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

# Converts the detailed description of services to latex for the table
render_invoice.latextbl <- function(
    data, csym
) {
  d <- data %>%
    mutate(
      Compensation = paste0(Compensation, " ", csym),
      Total = paste0(Total, " ", csym),
      across(where(is.factor), as.character)
    )

  ncolumns <- ncol(d)
  drows <- character(ncolumns+1)

  nms <- paste0(paste0("\\textbf{", names(d), "}", collapse = " & "), " \\\\ ")

  for (n in 1:ncolumns) {
    drows[n] <- paste0(d[n,], collapse = " & ")
  }

  coljust <- paste0("T ", paste0(rep("C", ncolumns-1), collapse = " "))

  list(
    paste0(drows, collapse = " \\\\ "),
    nms,
    coljust
    )
}


# Constructs intro text in case it wasn't provided.
render_invoice.introtext <- function(
    intro, proj_name, with
){

  if (!is.null(intro)) {
    intro_text <- intro
  } else {
    if (!is.null(proj_name) & !is.null(with)) {
      intro_text <- paste0(
        "My invoice in relation to the project ", proj_name, " with ", with, " amounts to:"
      )
    } else if (!is.null(proj_name) & is.null(with)) {
      intro_text <- paste0(
        "My invoice in relation to the project ", proj_name, " amounts to:"
      )
    } else if (is.null(proj_name) & !is.null(with)) {
      intro_text <- paste0(
        "My invoice in relation to the project with ", with, " amounts to:"
      )
    } else if (is.null(proj_name) & is.null(with)) {
      intro_text <- "For the services detailed below, my invoice amounts to:"
    }
  }

  intro_text

}


