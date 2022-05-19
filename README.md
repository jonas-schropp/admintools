# Installation

This is not on CRAN and will most likely never be on CRAN. It’s designed
to help me with creating invoices first and foremost, and if it helps
you/inspires you to do so as well, good.  
Installation via `devtools`:

    devtools::install_github("jonas-schropp/admintools")

And then load it like any other library

    library(admintools)

# Overview

`admintools` comes with two syntetic data sets to illustrate usage and
to make starting out and testing easier: `addresses` and `timesheets`.
`addresses` is a data.frame containing contact information for several
hypothetical clients. For simplicity it also contains the “sender”
address in the first line in order to facilitate creating the header for
invoices.

    str(addresses)

    ## 'data.frame':    10 obs. of  13 variables:
    ##  $ Client      : chr  "talynsight" "Client A" "Client B" "Client C" ...
    ##  $ street      : chr  "Sepapaja tn 6" "23 Random Street" "84 Some Street" "8 Avenue" ...
    ##  $ city        : chr  "Tallinn" "San Francisco" "Los Angeles" "New York" ...
    ##  $ zip_code    : chr  "11415" "CA 94131" "CA 90027" "NY 10002" ...
    ##  $ country     : chr  "Estonia" "USA" "USA" "USA" ...
    ##  $ email       : chr  "jonas.schropp@protonmail.com" "email@clienta.com" "email@clientb.com" "email@clientc.com" ...
    ##  $ phone       : chr  NA "+1(0)12345678" "+1(0)12345678" "+1(0)12345678" ...
    ##  $ vat_id      : chr  "EE102496143" "12345678" "12345678" "12345678" ...
    ##  $ organization: chr  "talynsight OÜ" "Client A Ltd" "Client B University" "Client C Ltd" ...
    ##  $ ref         : chr  "Jonas Schropp" NA "Albert Einstein" "Bill Gates" ...
    ##  $ ref_code    : chr  NA NA "B-123" "44E" ...
    ##  $ ref_email   : chr  "jonas.schropp@protonmail.com" NA "albi@email.com" "billyboy@microsoft.com" ...
    ##  $ VAT         : chr  "Reverse Charge" "Reverse Charge" "Reverse Charge" "Reverse Charge" ...

`timesheets` is an example how a timesheet to track work could look
like.

    str(timesheet)

    ## 'data.frame':    80 obs. of  9 variables:
    ##  $ Date        : Date, format: "2022-01-07" "2022-01-08" ...
    ##  $ Client      : chr  "Client B" "Client B" "Client B" "Client C" ...
    ##  $ Project     : chr  "Project 1" "Project 3" "Project 2" "Project X" ...
    ##  $ With        : chr  "PI 2" "PI 1" "PI 2" NA ...
    ##  $ Task        : chr  "data analysis" "data analysis" "reporting" "meeting" ...
    ##  $ Description : chr  "Stately, plump Buck Mulligan came from the stairhead, bearing a bowl of lather on which a \n    mirror and a ra"| __truncated__ " —Introibo ad altare Dei." "Halted, he peered down the dark winding stairs and called out coarsely:" " —Come up, Kinch! Come up, you fearful jesuit!" ...
    ##  $ Hours       : int  4 5 8 9 6 7 5 9 8 9 ...
    ##  $ Hourly      : num  90 90 90 120 90 120 90 120 120 120 ...
    ##  $ Compensation: num  360 450 720 1080 540 840 450 1080 960 1080 ...

The package has two main functions: `comp_table` and `render_invoice`.

-   `comp_table` is mostly a wrapper over several `dplyr` functions for
    aggregating and summarizing data that can be used to easily and
    quickly transform data from the timesheet into a format that is
    useful for reporting.
-   `render_invoice` renders an invoice in pdf format, using either the
    template supplied with this package or a template of your own. If
    you want to use your own template, try to work around the existing
    one and only change the styling of the output rather than the
    content - otherwise the code will likely break because
    `render_invoice` performs quite a lot of computation to transform
    the R output into LaTeX code even before passing it on to
    `rmarkdown`.

# Examples

## Create some aggregated tables using `comp_table`

Pick everything from Client B, don’t perform any more aggregation or
filtering:

    comp_table(
      data = timesheet,
      client_name = "Client B"
      )

    ## # A tibble: 29 × 6
    ##    Month    Task                Project   Hours Compensation Total
    ##    <fct>    <chr>               <chr>     <int>        <dbl> <dbl>
    ##  1 January  data analysis       Project 1     4          360   360
    ##  2 January  data analysis       Project 3    17         1530  1890
    ##  3 January  predictive modeling Project 1     5          450  2340
    ##  4 January  reporting           Project 2    22         1980  4320
    ##  5 February data analysis       Project 1    28         2520  6840
    ##  6 February data analysis       Project 3     8          720  7560
    ##  7 February NLP                 Project 2     9          810  8370
    ##  8 February NLP                 Project 3     5          450  8820
    ##  9 February predictive modeling Project 2    15         1350 10170
    ## 10 February reporting           Project 1     5          450 10620
    ## # … with 19 more rows

Summarize for yourself how much time you spent on each specific task
during a specified time period:

    comp_table(
      data = timesheet,
      agg_by = "Task",
      min_date = as.Date("2022-01-01"),
      max_date = as.Date("2022-04-30")
      )

    ## # A tibble: 5 × 4
    ##   Task                Hours Compensation Total
    ##   <chr>               <int>        <dbl> <dbl>
    ## 1 data analysis         117        11670 11670
    ## 2 meeting                59         6180 17850
    ## 3 NLP                   140        14340 32190
    ## 4 predictive modeling    76         8010 40200
    ## 5 reporting             144        14970 55170

Do the same, but only for a specific project:

    comp_table(
      data = timesheet,
      agg_by = "Task",
      min_date = as.Date("2022-01-01"),
      max_date = as.Date("2022-04-30"),
      proj_name = "Project 1"
      )

    ## # A tibble: 5 × 4
    ##   Task                Hours Compensation Total
    ##   <chr>               <int>        <dbl> <dbl>
    ## 1 data analysis          32         2880  2880
    ## 2 meeting                19         1710  4590
    ## 3 NLP                    14         1260  5850
    ## 4 predictive modeling    11          990  6840
    ## 5 reporting              19         1710  8550

## Create an invoice

In order to create invoices, it’s necessary to first aggregate and
filter your timesheet and then pass it on to `render_invoice`.

If we want to create an invoice for all the work we’ve ever done for
*Client A*, each task reported in detail:

    timesheet %>%
      comp_table(
        client_name = "Client A"
      ) %>%
      render_invoice(
        client = filter(addresses, Client == "Client A"),
        address = filter(addresses, Client == "talynsight"),
        inv_number = "20570",
        iban = "DE12345678",
        bic = "BLABLA01",
        bank = "Parkbank"
      )

A lot more customization is possible too, for example we can customize
the introduction text by specifying *proj\_name* and *with* (or fully
customized via *intro*) and add a discount:

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
        iban = "DE12345678",
        bic = "BLABLA01",
        bank = "Parkbank",
        with = "PI Jim Lahey, Trailer Park Supervisor,",
        discount = "10%",
        VAT = "Reverse Charge",
        currency = "Euro",
        filename = paste0(Sys.Date(), "-talynsightOÜ-ClientB-10098.pdf")
     )
