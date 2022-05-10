#' Creates a detailed table for compensation
#' Containing the hours worked on a specific project within a specified timeframe
#' Follows lazy evaluation
#'
#' @param data A data.frame/tibble/tidytable/matrix containing project data
#' @param mindate A date in the format as.Date("yyyy-mm-dd")
#' @param maxdate A date in the format as.Date("yyyy-mm-dd")
#' @param Date Name of the Date column in your data set
#' @param Hours Name of the Hours column in your data set
#' @param Compensation Name of the Compensation column in your data set
#' @param Project Name of the Project column in your data set
#' @param Client Name of the Client column in your data set
#' @param Task Name of the column containing a Short description of the task carried out in specified time frame
#' @return A formatted table of compensation grouped by either combination of month, project and client.
#' @export
#' @import dplyr
#' @importFrom knitr kable
#' @examples
#' report_single(df)
#' report_single(df, mindate = as.Date("2022-01-01"), maxdate = as.Date("2022-04-30"), proj_name = "FIMADIA", pi = "Naomi Lange")
#' report_single(df, Project = Project, minmonth = 2, maxmonth = 3)


report_single <- function(
    data,
    mindate,
    maxdate,
    proj_name,
    pi = NULL,
    cpt = NULL,
    Date = Date, Hours = Hours, Compensation = Compensation, Project = Project, Task = Task
    ) {

  p <- data %>%
    filter(
      {{ Project }} == proj_name,
      {{ Date }} >= mindate & {{ Date }} <= maxdate
    )

  if(is.null(cpt) & !is.null(pi)) {
    cpt <- paste0("Project '", proj_name, "' with ", pi)
  } else if(is.null(cpt) & is.null(pi)) {
    cpt <- paste0("Project '", proj_name)
  }


  p %>%
    select({{ Date }}, {{ Task }}, {{ Hours }}, {{ Compensation }}) %>%
    arrange({{ Date }}) %>%
    mutate(Total = cumsum({{ Compensation }})) %>%
    kable(caption = cpt)
}

