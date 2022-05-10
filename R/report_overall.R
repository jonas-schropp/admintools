#' Creates an overview table for compensation
#' Can be grouped by either combination of month, project and client
#' Follows lazy evaluation
#'
#' @param data A data.frame/tibble/tidytable/matrix containing project data
#' @param availablecomp Either the available funding at the beginning of the project or NULL if invoice is to be given after the project.
#' @param minmonth A number, the first month to consider
#' @param maxmonth A number, the last month to consider
#' @param Month Name of the Month column in your data set
#' @param Hours Name of the Hours column in your data set
#' @param Compensation Name of the Compensation column in your data set
#' @param Project Name of the Project column in your data set
#' @param Client Name of the Client column in your data set
#' @return A formatted table of compensation grouped by either combination of month, project and client.
#' @export
#' @import dplyr
#' @importFrom knitr kable
#' @examples
#' report_overall(df)
#' report_overall(df, Project = Project)
#' report_overall(df, Project = Project, minmonth = 2, maxmonth = 3)

report_overall <- function(
    data,
    availablecomp = 11683,
    minmonth = 1,
    maxmonth = 4,
    cpt = "Overview over total monthly compensation and remaining budget",
    Month = Month, Hours = Hours, Compensation = Compensation, Project = NULL, Client = NULL
    ) {

  ms <- month.name[minmonth:maxmonth]

  data <- data %>%
    filter({{ Month }} %in% ms) %>%
    group_by({{ Month }}, {{ Project }}, {{ Client }}) %>%
    summarise(
      Hours = sum({{ Hours }}),
      Compensation = sum({{ Compensation }}),
      .groups = "keep"
    ) %>%
    ungroup() %>%
    mutate(
      Total = cumsum(Compensation)
    )

  if(!is.null(availablecomp)) {
    data <- data %>%
      mutate(Remaining = availablecomp - Total)
  }

  kable(data, caption = cpt)

}




