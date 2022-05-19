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

    suppressPackageStartupMessages(library(dplyr))

## Create some aggregated tables using `comp_table`

Pick everything from Client B, don’t perform any more aggregation or
filtering:

    comp_table(
      data = timesheet,
      client_name = "Client B"
      ) %>%
      knitr::kable()

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Month</th>
<th style="text-align: left;">Task</th>
<th style="text-align: left;">Project</th>
<th style="text-align: right;">Hours</th>
<th style="text-align: right;">Compensation</th>
<th style="text-align: right;">Total</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">January</td>
<td style="text-align: left;">data analysis</td>
<td style="text-align: left;">Project 1</td>
<td style="text-align: right;">4</td>
<td style="text-align: right;">360</td>
<td style="text-align: right;">360</td>
</tr>
<tr class="even">
<td style="text-align: left;">January</td>
<td style="text-align: left;">data analysis</td>
<td style="text-align: left;">Project 3</td>
<td style="text-align: right;">17</td>
<td style="text-align: right;">1530</td>
<td style="text-align: right;">1890</td>
</tr>
<tr class="odd">
<td style="text-align: left;">January</td>
<td style="text-align: left;">predictive modeling</td>
<td style="text-align: left;">Project 1</td>
<td style="text-align: right;">5</td>
<td style="text-align: right;">450</td>
<td style="text-align: right;">2340</td>
</tr>
<tr class="even">
<td style="text-align: left;">January</td>
<td style="text-align: left;">reporting</td>
<td style="text-align: left;">Project 2</td>
<td style="text-align: right;">22</td>
<td style="text-align: right;">1980</td>
<td style="text-align: right;">4320</td>
</tr>
<tr class="odd">
<td style="text-align: left;">February</td>
<td style="text-align: left;">data analysis</td>
<td style="text-align: left;">Project 1</td>
<td style="text-align: right;">28</td>
<td style="text-align: right;">2520</td>
<td style="text-align: right;">6840</td>
</tr>
<tr class="even">
<td style="text-align: left;">February</td>
<td style="text-align: left;">data analysis</td>
<td style="text-align: left;">Project 3</td>
<td style="text-align: right;">8</td>
<td style="text-align: right;">720</td>
<td style="text-align: right;">7560</td>
</tr>
<tr class="odd">
<td style="text-align: left;">February</td>
<td style="text-align: left;">NLP</td>
<td style="text-align: left;">Project 2</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">810</td>
<td style="text-align: right;">8370</td>
</tr>
<tr class="even">
<td style="text-align: left;">February</td>
<td style="text-align: left;">NLP</td>
<td style="text-align: left;">Project 3</td>
<td style="text-align: right;">5</td>
<td style="text-align: right;">450</td>
<td style="text-align: right;">8820</td>
</tr>
<tr class="odd">
<td style="text-align: left;">February</td>
<td style="text-align: left;">predictive modeling</td>
<td style="text-align: left;">Project 2</td>
<td style="text-align: right;">15</td>
<td style="text-align: right;">1350</td>
<td style="text-align: right;">10170</td>
</tr>
<tr class="even">
<td style="text-align: left;">February</td>
<td style="text-align: left;">reporting</td>
<td style="text-align: left;">Project 1</td>
<td style="text-align: right;">5</td>
<td style="text-align: right;">450</td>
<td style="text-align: right;">10620</td>
</tr>
<tr class="odd">
<td style="text-align: left;">February</td>
<td style="text-align: left;">reporting</td>
<td style="text-align: left;">Project 3</td>
<td style="text-align: right;">6</td>
<td style="text-align: right;">540</td>
<td style="text-align: right;">11160</td>
</tr>
<tr class="even">
<td style="text-align: left;">March</td>
<td style="text-align: left;">data analysis</td>
<td style="text-align: left;">Project 2</td>
<td style="text-align: right;">5</td>
<td style="text-align: right;">450</td>
<td style="text-align: right;">11610</td>
</tr>
<tr class="odd">
<td style="text-align: left;">March</td>
<td style="text-align: left;">meeting</td>
<td style="text-align: left;">Project 1</td>
<td style="text-align: right;">15</td>
<td style="text-align: right;">1350</td>
<td style="text-align: right;">12960</td>
</tr>
<tr class="even">
<td style="text-align: left;">March</td>
<td style="text-align: left;">meeting</td>
<td style="text-align: left;">Project 2</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">630</td>
<td style="text-align: right;">13590</td>
</tr>
<tr class="odd">
<td style="text-align: left;">March</td>
<td style="text-align: left;">meeting</td>
<td style="text-align: left;">Project 3</td>
<td style="text-align: right;">4</td>
<td style="text-align: right;">360</td>
<td style="text-align: right;">13950</td>
</tr>
<tr class="even">
<td style="text-align: left;">March</td>
<td style="text-align: left;">NLP</td>
<td style="text-align: left;">Project 2</td>
<td style="text-align: right;">13</td>
<td style="text-align: right;">1170</td>
<td style="text-align: right;">15120</td>
</tr>
<tr class="odd">
<td style="text-align: left;">March</td>
<td style="text-align: left;">NLP</td>
<td style="text-align: left;">Project 3</td>
<td style="text-align: right;">17</td>
<td style="text-align: right;">1530</td>
<td style="text-align: right;">16650</td>
</tr>
<tr class="even">
<td style="text-align: left;">March</td>
<td style="text-align: left;">predictive modeling</td>
<td style="text-align: left;">Project 1</td>
<td style="text-align: right;">6</td>
<td style="text-align: right;">540</td>
<td style="text-align: right;">17190</td>
</tr>
<tr class="odd">
<td style="text-align: left;">March</td>
<td style="text-align: left;">predictive modeling</td>
<td style="text-align: left;">Project 3</td>
<td style="text-align: right;">11</td>
<td style="text-align: right;">990</td>
<td style="text-align: right;">18180</td>
</tr>
<tr class="even">
<td style="text-align: left;">March</td>
<td style="text-align: left;">reporting</td>
<td style="text-align: left;">Project 1</td>
<td style="text-align: right;">14</td>
<td style="text-align: right;">1260</td>
<td style="text-align: right;">19440</td>
</tr>
<tr class="odd">
<td style="text-align: left;">March</td>
<td style="text-align: left;">reporting</td>
<td style="text-align: left;">Project 2</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">630</td>
<td style="text-align: right;">20070</td>
</tr>
<tr class="even">
<td style="text-align: left;">March</td>
<td style="text-align: left;">reporting</td>
<td style="text-align: left;">Project 3</td>
<td style="text-align: right;">8</td>
<td style="text-align: right;">720</td>
<td style="text-align: right;">20790</td>
</tr>
<tr class="odd">
<td style="text-align: left;">April</td>
<td style="text-align: left;">data analysis</td>
<td style="text-align: left;">Project 2</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">630</td>
<td style="text-align: right;">21420</td>
</tr>
<tr class="even">
<td style="text-align: left;">April</td>
<td style="text-align: left;">data analysis</td>
<td style="text-align: left;">Project 3</td>
<td style="text-align: right;">10</td>
<td style="text-align: right;">900</td>
<td style="text-align: right;">22320</td>
</tr>
<tr class="odd">
<td style="text-align: left;">April</td>
<td style="text-align: left;">meeting</td>
<td style="text-align: left;">Project 1</td>
<td style="text-align: right;">4</td>
<td style="text-align: right;">360</td>
<td style="text-align: right;">22680</td>
</tr>
<tr class="even">
<td style="text-align: left;">April</td>
<td style="text-align: left;">NLP</td>
<td style="text-align: left;">Project 1</td>
<td style="text-align: right;">14</td>
<td style="text-align: right;">1260</td>
<td style="text-align: right;">23940</td>
</tr>
<tr class="odd">
<td style="text-align: left;">April</td>
<td style="text-align: left;">NLP</td>
<td style="text-align: left;">Project 2</td>
<td style="text-align: right;">17</td>
<td style="text-align: right;">1530</td>
<td style="text-align: right;">25470</td>
</tr>
<tr class="even">
<td style="text-align: left;">April</td>
<td style="text-align: left;">NLP</td>
<td style="text-align: left;">Project 3</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">630</td>
<td style="text-align: right;">26100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">April</td>
<td style="text-align: left;">reporting</td>
<td style="text-align: left;">Project 3</td>
<td style="text-align: right;">15</td>
<td style="text-align: right;">1350</td>
<td style="text-align: right;">27450</td>
</tr>
</tbody>
</table>

Summarize for yourself how much time you spent on each specific task
during a specified time period:

    comp_table(
      data = timesheet,
      agg_by = "Task",
      min_date = as.Date("2022-01-01"),
      max_date = as.Date("2022-04-30")
      ) %>%
      knitr::kable()

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Task</th>
<th style="text-align: right;">Hours</th>
<th style="text-align: right;">Compensation</th>
<th style="text-align: right;">Total</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">data analysis</td>
<td style="text-align: right;">117</td>
<td style="text-align: right;">11670</td>
<td style="text-align: right;">11670</td>
</tr>
<tr class="even">
<td style="text-align: left;">meeting</td>
<td style="text-align: right;">59</td>
<td style="text-align: right;">6180</td>
<td style="text-align: right;">17850</td>
</tr>
<tr class="odd">
<td style="text-align: left;">NLP</td>
<td style="text-align: right;">140</td>
<td style="text-align: right;">14340</td>
<td style="text-align: right;">32190</td>
</tr>
<tr class="even">
<td style="text-align: left;">predictive modeling</td>
<td style="text-align: right;">76</td>
<td style="text-align: right;">8010</td>
<td style="text-align: right;">40200</td>
</tr>
<tr class="odd">
<td style="text-align: left;">reporting</td>
<td style="text-align: right;">144</td>
<td style="text-align: right;">14970</td>
<td style="text-align: right;">55170</td>
</tr>
</tbody>
</table>

Do the same, but only for a specific project:

    comp_table(
      data = timesheet,
      agg_by = "Task",
      min_date = as.Date("2022-01-01"),
      max_date = as.Date("2022-04-30"),
      proj_name = "Project 1"
      ) %>%
      knitr::kable()

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Task</th>
<th style="text-align: right;">Hours</th>
<th style="text-align: right;">Compensation</th>
<th style="text-align: right;">Total</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">data analysis</td>
<td style="text-align: right;">32</td>
<td style="text-align: right;">2880</td>
<td style="text-align: right;">2880</td>
</tr>
<tr class="even">
<td style="text-align: left;">meeting</td>
<td style="text-align: right;">19</td>
<td style="text-align: right;">1710</td>
<td style="text-align: right;">4590</td>
</tr>
<tr class="odd">
<td style="text-align: left;">NLP</td>
<td style="text-align: right;">14</td>
<td style="text-align: right;">1260</td>
<td style="text-align: right;">5850</td>
</tr>
<tr class="even">
<td style="text-align: left;">predictive modeling</td>
<td style="text-align: right;">11</td>
<td style="text-align: right;">990</td>
<td style="text-align: right;">6840</td>
</tr>
<tr class="odd">
<td style="text-align: left;">reporting</td>
<td style="text-align: right;">19</td>
<td style="text-align: right;">1710</td>
<td style="text-align: right;">8550</td>
</tr>
</tbody>
</table>

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
        filename = paste0(Sys.Date(), "-talynsightOÜ-ClientB-10098.pdf"),
        dir = "C:/invoices"
     )

When you run this code, first a window with the newly created .Rmd file
will pop up. Click ok and the pdf will be rendered to the directory you
specified.
