library(ggvis)
library(dplyr)
library(wordcloud)

# Set up DB from csv file
all_teams <- tbl_df(read.csv("regular_db.csv", 
                             stringsAsFactors = FALSE))


function(input, output, session) {
  # Define a reactive expression
  teams <- reactive({
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
    
    # Optional: filter by typing team name
    if (!is.null(input$name) && input$name != "") {
      name <- tolower(input$name)
      t <- t %>% 
        filter(grepl(name, 
                     tolower(TeamName), 
                     fixed=TRUE))
    }


    t <- as.data.frame(t)
    
    # Add column for indicating the number of championships
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

    all_teams <- isolate(teams()) 
    team <- all_teams[all_teams$Uniq == x$Uniq, ]
  
    paste0("<b>", team$TeamName, "</b><br>",
      team$Season, "<br>",
      "W-", team$NumWin, " L-", team$NumLost, "<br>",
      team$Description
    )
  }
  # Reactive expression for ggvis plot
  vis <- reactive({
    # Lables for axes
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]

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
      add_legend("stroke", 
                 title = "Championship*", 
                 values = c("None", 
                            "Single", 
                            "Double", 
                            "Treble")) %>%
      scale_nominal("stroke", 
                    domain = c("None", 
                               "Single", 
                               "Double", 
                               "Treble"),
        range = c("#aaa","#ffcb05", "#00274c", "#FF1493")) %>%
      set_options(width = 700, height = 500)
  })
  
  # output for the first tab
  output$plot1 <- vis %>% bind_shiny("plot1")
  
  # output for the second tab
  output$plot2 <- renderPlot({
    tem <- teams()
    tem <- tem %>% 
      filter(Seed>0) %>% 
      group_by(TeamName) %>%
      summarize('NumWin2'=sum(NumWin))
    
    wordcloud(words = tem$TeamName,
              freq = tem$NumWin2,
              min.freq = 15,
              max.words = 58,
              random.order = F,
              rot.per = 0.1, 
              scale = c(1.8, 0.25),
              colors = brewer.pal(8, "Dark2")
              )
  }
  )
  # output for well panel at the bottom
  output$n_teams <- renderText({nrow(teams())})
  
  # output for the third tab
  output$table <- renderDataTable(teams() %>% 
                                    select(Season, 
                                           TeamName,  
                                           "Win"=NumWin, 
                                           "Lost"=NumLost, 
                                           "Win%"=Win,
                                           Avg.Score, 
                                           Seed, 
                                           NumChamp)
                                  )
}
