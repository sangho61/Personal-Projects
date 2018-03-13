library(ggvis)
library(dplyr)



# Set up DB from csv file
all_teams <- tbl_df(read.csv("regular_db.csv", stringsAsFactors = FALSE))


function(input, output, session) {

  # Filter the movies, returning a data frame
  teams <- reactive({
    # Due to dplyr issue #318, we need temp variables for input values
    wins_n <- input$wins_n
    seed_n <- input$seed_n
    minyear <- input$year[1]
    maxyear <- input$year[2]

    # Apply filters
    t <- all_teams %>%
      filter(
        NumWin >= wins_n,
        Season >= minyear,
        Season <= maxyear
      ) 

    # Optional: filter by power conference
    if (input$power != "Choose") {
      power <- paste0(input$power)
      t <- t %>% filter(Description == power)
    }
    # Optional: filter by director
    if (!is.null(input$name) && input$name != "") {
      name <- input$name
      t <- t %>% filter(grepl(name, TeamName, fixed=TRUE))
    }


    t <- as.data.frame(t)

    # Add column which says whether the movie won any Oscars
    # Be a little careful in case we have a zero-row data frame
    t$champs <- character(nrow(t))
    t$champs[t$NumChamp == 0] <- "None"
    t$champs[t$NumChamp == 1] <- "Single"
    t$champs[t$NumChamp == 2] <- "Double"
    t$champs[t$NumChamp == 3] <- "Treble"
    t
  })

  # Function for generating tooltip text
  tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$Uniq)) return(NULL)

    # Pick out the movie with this ID
    all_teams <- isolate(teams()) 
    team <- all_teams[all_teams$Uniq == x$Uniq, ]
  
    paste0("<b>", team$TeamName, "</b><br>",
      team$Season, "<br>",
      "$", format(team$Description, big.mark = ",", scientific = FALSE)
    )
  }

  # A reactive expression with the ggvis plot
  vis <- reactive({
    # Lables for axes
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]

    # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
    # but since the inputs are strings, we need to do a little more work.
    xvar <- prop("x", as.symbol(input$xvar)) 
    yvar <- prop("y", as.symbol(input$yvar))

    teams %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 50, size.hover := 200,
        fillOpacity := 0.2, fillOpacity.hover := 0.5,
        stroke = ~champs, key := ~Uniq) %>%
      add_tooltip(tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      add_axis("y", title = yvar_name) %>%
      add_legend("stroke", title = "Championship", values = c("None", "Single", "Double", "Treble")) %>%
      scale_nominal("stroke", domain = c("None", "Single", "Double", "Treble"),
        range = c("#aaa","#ffcb05", "#00274c", "#FF1493")) %>%
      set_options(width = 700, height = 500)
  })

  vis %>% bind_shiny("plot1")

  output$n_teams <- renderText({ nrow(teams())})
}
