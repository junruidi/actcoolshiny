library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title or header
  titlePanel(title = h4("Analysis of Activity Count Data",align="center")),
  tags$hr(),
  sidebarLayout(
    # siderbar panel
    sidebarPanel(
      fileInput("file","Please upload your file"),
      tags$hr(),
      bootstrapPage(
      div(style = "display:block",uiOutput("idchoices")),
      div(style = "display:block",uiOutput("daychoices")),
      div(style = "display:block", uiOutput("threshold"))
      ),
      
      tags$hr(),
      bootstrapPage(
      h4("Save to Local"),
      downloadButton("download.summary.button","Download Summary"),
      #div(style = "display:block", uiOutput("download.summary.button")),
      h1(""),
      downloadButton("downloadflagbutton","Download WNW Flag")
      #div(style = "display:block", uiOutput("downloadflagbutton"))     
      ),
      
      hr(),
      bootstrapPage(
        h4("Save to Dropbox"),
        actionButton("uploadact", "Upload Act to Dropbox"),
        h1(""),
        actionButton("uploadflag", "Upload WNW to Dropbox"),
        h1(""),
        actionButton("uploadsummary", "Upload Summary to Dropbox")    
      )
      

    ),
    
    mainPanel(
        tabsetPanel(
                    tabPanel("Summary",value = 2,
                             h4(verbatimTextOutput("summarytitle"),align = "center"),
                             tableOutput("sum"),
                             br(),
                             h3("Definitions of Summary"),
                             h4("Regular Summary:"),
                             helpText("TLAC: total log transformation of activity data"),
                             helpText("sedtime: Daily sedentary time"),
                             helpText("acttime: Daily active time"),
                             helpText("weartime: Total daily wearing time"),
                             h4("Fragmentation Index:"),
                             helpText("lambr, lamba:  recripocal of average duration"),
                             helpText("gr, gr: gini index"),
                             helpText("hr, ha: average hazard funtions")),
                    tabPanel("Plot", value = 3, plotOutput("plot")),
                    tabPanel("Data Donation", value = 3, h4("Users can download fitbit data"),
                             bootstrapPage(
                               h4("(For current version, this feature only works on local PC, please download it and run the app locally)"),
                               textInput("key", label = "Fitbit Key",value = "227YWF"),
                               textInput("secret", label = "Fitbit Secret",value = "aa07049ff79a741122ee92776039e5ce"),
                               textInput("date", label = "Date (e.g. 2016-11-21)",value = "2016-11-21"),
                               textInput("subid",label = "Privde subject ID (numberic, e.g. 890802)",value = "890802"),
                               downloadButton("fitbitdata","Download"),
                               hr(),
                               actionButton("combine", "Donate to current data")
                             )
                             ),
          id = "tabselected"
          )
    )
  )
))


