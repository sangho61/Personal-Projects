library(ggvis)
library(shinythemes)
library(wordcloud)

# For dropdown menu
actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}

fluidPage(theme = shinytheme("sandstone"),
  titlePanel("NCAA Explorer (2003-2017) by Sangho Eum"),
  fluidRow(
    column(3,
      wellPanel(
        h4("Filter"),
        sliderInput("wins_n", "Min. Wins per season",
          1, 34, 15, step = 1),
        sliderInput("year", "Season Year", 2003, 2017, 
                    value = c(2003, 2017)),
        selectInput("power", "Power 6 Conference",
          c("Choose", 
            "Atlantic Coast Conference", 
            "Big East Conference", 
            "Big Ten Conference",
            "Big 12 Conference", 
            "Pacific-12 Conference", 
            "Southeastern Conference")
        ),
        textInput("name", "Team Name")
      ),
      wellPanel(
        selectInput("xvar", "X-axis", 
                    axis_vars, 
                    selected = "Avg.Score"),
        selectInput("yvar", "Y-axis", 
                    axis_vars, 
                    selected = "Win")
      )
    ),
    mainPanel(
      
      # create tab
      tabsetPanel(type = "tabs",
                  tabPanel("Plot", 
                           ggvisOutput("plot1")),
                  tabPanel("Word Cloud by Wins", 
                           plotOutput("plot2")),
                  tabPanel("Table", 
                           dataTableOutput("table")) 
      )
    ),
    column(9,
      wellPanel(
        span("Number of Teams selected:",
          textOutput("n_teams")
        )
      )
    )
  )
)
