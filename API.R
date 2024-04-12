# Loading necessary libraries
library(shiny)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(glue)
library(jsonlite)

# The following line will load all of your R code from the qmd
# this will make your get_nyt_articles function available to your
# shiny app.
source(
  knitr::purl("midterm2.qmd", output=tempfile(), quiet=TRUE)
)

# Define the User Interface (UI) layout
ui = fluidPage(
  titlePanel(h3("New York Times API", style = "color: black")), # Title panel
  sidebarLayout(
    sidebarPanel(
      dateInput("date", "Date", value = "2019-01-01"), # Date input for user
      textInput("api", "API Key", value = "FZtw5VD04y6MB2lZJyUrpXdJBWGr3IbR"), # API key input
      actionButton("search", "Search") # Search button
    ),
    mainPanel(
      uiOutput("links") # Output area for links
    )
  )
)

# Define Server logic
server <- function(input, output, session) {
  state <- reactiveValues(observers = list())
  
  observeEvent(input$search, {
    # Destroy existing observers
    if (!is.null(state$observers)) {
      for (observer in state$observers) {
        observer$destroy()
      }
    }
    state$observers <- list()
    
    tryCatch({
    # Extract date and API key, and call your API function
    date <- format(input$date, "%Y-%m-%d")
    articles <- get_nyt_articles(as.integer(substr(date, 1, 4)), 
                                 as.integer(substr(date, 6, 7)), 
                                 as.integer(substr(date, 9, 10)), 
                                 input$api)
    
    # Check if articles are empty
    if(all(is.na(articles))) {
      output$links <- renderUI({ "No articles found for this date." })
      return()
    }
    
    # Create UI elements for each article
    ui_elems <- lapply(1:nrow(articles), function(i) {
      fluidRow(actionLink(paste0("link", i), articles[["headline"]][[i]]$main, style = "color: black"))
    })
    output$links <- renderUI({do.call(fluidPage, ui_elems)}) # Render links in the UI
    
    # Create observers for each link
    state$observers <- lapply(1:nrow(articles), function(i) {
      observeEvent(input[[paste0("link", i)]], ignoreInit = TRUE, {
        # include the first picture from each article
        # Check if the "url" exists
        if (!any(is.na(articles[["multimedia"]]))) { 
          # By testing on date 1980/05/16, in which "multimedia" is empty, the type is NA. 
          # So I use is.na to check here. 
          # The logic here is TRUE only if all values are non-NA (no missing values at all)
          
          # If the 'url' is found, prepend the base URL
          image_url <- paste0("https://www.nytimes.com/", articles[["multimedia"]][[i]][[1]][["url"]])
        } else {
          # If the 'url' is not found, use the default image URL
          image_url <- "https://nytco-assets.nytimes.com/2018/09/TIMES_JEENAH_0212.jpg?quality=70&auto=webp&crop=16:9&width=2000"}
        
        showModal(modalDialog(
          title = articles[["headline"]][[i]]$main, 
          h4("Byline"),
          articles[["byline"]][[i]]$original,
          h4("Lead Paragraph"),
          articles$lead_paragraph[i],
          h4("Url"), 
          tags$a(href = articles$web_url[i], "Read full article", target = "_blank"),
          tags$img(src = image_url, style = "width:100%;height:auto;")
        ))
      })
    })
    }, warning = function(w) {
      # Check if the warning is related to Unauthorized access
      if (grepl("401 Unauthorized", w$message)) {
        output$links <- renderUI({"Invalid API key. Please check your API key and try again."})
      } else {
        output$links <- renderUI({"An error occurred. Please try again later."})
      }
    })
  })
}

# Run the Shiny application
shinyApp(ui = ui, server = server)
