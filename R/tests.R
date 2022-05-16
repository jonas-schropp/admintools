
'
timesheet %>%
  comp_table(
    client_name = "Client B",
    proj_name = "Project 1",
    agg_by = "Month",
    min_date = as.Date("2022-01-01"),
    max_date = as.Date("2022-04-30")
    ) %>%
render_invoice(
     client = filter(addresses, Client == "Client B"),
     address = filter(addresses, Client == "talynsight"),
     proj_name = "Project 1",
     inv_number = "10098",
     with = "PI Buck Mulligan, PhD",
     discount = "10%"
     )
'
