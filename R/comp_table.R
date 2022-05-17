#' Creates a detailed table for compensation
#' Containing the hours worked on a specific project within a specified timeframe
#' Uses lazy evaluation
#'
#' @param data A data.frame containing project data
#' @param agg_by NULL if detailed item-by-item output is desired, a character vector with one or more of "Month", "Task", "Project" otherwise
#' @param mindate A date in the format as.Date("yyyy-mm-dd")
#' @param maxdate A date in the format as.Date("yyyy-mm-dd")
#' @param proj_name If output for only one project is desired, the name of the project
#' @param client_name If output for only one client is desired, the name of the client
#' @param available_comp If working on a retainer basis, the amount of money available at the start of the project
#' @param date Name of the Date column in your data set
#' @param hours Name of the Hours column in your data set
#' @param compensation Name of the Compensation column in your data set
#' @param project Name of the Project column in your data set
#' @param client Name of the Client column in your data set
#' @param task Name of the column containing a Short description of the task carried out in specified time frame
#' @param table should a kable be returned or the raw data.frame?
#' @return A formatted table of compensation grouped by either combination of month, project and client.
#' @export
#' @import dplyr
#' @import assertthat
#' @examples
#' comp_table(data = timesheet, client_name = "Client B")
#' comp_table(data = timesheet, agg_by = "Task", min_date = as.Date("2022-01-01"), max_date = as.Date("2022-04-30"))
#' comp_table(data = timesheet, agg_by = "Task", min_date = as.Date("2022-01-01"), max_date = as.Date("2022-04-30"), proj_name = "Project 1")

comp_table <- function(
    data,
    agg_by = c("Month", "Task", "Project"),

    min_date = NULL,
    max_date = NULL,

    proj_name = NULL,
    client_name = NULL,

    available_comp = NULL,
    verbose = FALSE,

    date = Date,
    hours = Hours,
    compensation = Compensation,
    project = Project,
    task = Task,
    client = Client
) {

  # Run some simple tests to check that input makes sense
  assert_that(
    not_empty(proj_name) | not_empty(client_name),
    msg = "Error: Neither proj_name nor client_name specified"
  )

  data <- data %>%
    rename(
      Date = {{ date }},
      Hours = {{ hours }},
      Compensation = {{ compensation }},
      Project = {{ project }},
      Task = {{ task }},
      Client = {{ client }}
    )

  # Filter data set
  if(!is.null(proj_name)) { data <- filter(data, Project == proj_name) }
  if(!is.null(client_name)) { data <- filter(data, Client == client_name) }

  if(verbose) {
    if(is.null(min_date) & is.null(max_date)) {
      cat("\nNo min or max date specified, using entire available data.\n")
      }
  }

  if(!is.null(min_date)) { data <- filter(data, Date >= min_date) }
  if(!is.null(max_date)) { data <- filter(data, Date <= max_date) }

  # Split into helper functions
  if (is.null(agg_by)) {
    data <- comp_table.detailed(data = data)
  } else {
    data <- comp_table.aggregated(data = data, agg_by = agg_by)
  }

  if(!is.null(available_comp)) {
    data <- data %>% mutate(Remaining = available_comp - Total)
  }

  data

}




comp_table.aggregated <- function(data, agg_by) {

  data <- data %>%
    select(Date, Client, Project, Task, Hours, Compensation) %>%
    mutate(Month = factor(months.Date(Date), levels = month.name)) %>%
    group_by(across(all_of(agg_by))) %>%
    summarise(
      Hours = sum(Hours),
      Compensation = sum(Compensation)
    ) %>%
    ungroup() %>%
    mutate(Total = cumsum(Compensation))

  data

}







comp_table.detailed <- function(data) {

  data <- data %>%
    select(Date, Client, Project, Task, Hours, Compensation) %>%
    arrange(Client, Project, Date)

  lc <- length(unique(data$Client))
  lp <- length(unique(data$Project))

  if (lc > 1 & lp > 1) {
     data <- data
  } else if (lc > 1 & lp == 1) {
    data <- data %>% select(-Project)
  } else if (lc == 1 & lp > 1) {
    data <- data %>% select(-Client)
  } else if (lc == 1 & lp == 1){
    data <- data %>% select(-Project, -Client)
  } else (
    errorCondition(
      message = "Error: Number of Projects and Clients not 1 or bigger."
    )
  )

  data %>% mutate(Total = cumsum(Compensation))
}





