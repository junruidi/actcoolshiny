library(shiny)
#devtools::install_github("junruidi/actcool")
#devtools::install_github("teramonagi/fitbitr")
library(actcool)
library(accelerometry)
library(dplyr)
library(fitbitr)
library(httr)
library(rdrop2)


shinyServer(function(input, output) {
   
  # data = reactive({
  #     file1 = input$file
  #     if(is.null(file1)){return()}
  #     read.csv(file = file1$datapath)
  #   })
  Maindata <- reactiveValues()
  
  observe({
    file1 = input$file
    if(is.null(file1)){return()}
    Maindata$data <- read.csv(file = file1$datapath)
  })
  
  flag.all = reactive({ WNW_data(Maindata$data ) })
  
  selected = reactive({
    selct(data = Maindata$data ,
          id = as.numeric(input$ID), 
          day = as.numeric(input$Day))
  })
  
  flag.selected = reactive({
    WNW(x = selected())
  })
  

  
  output$filedf = renderTable({
    if(is.null(Maindata$data )){return()}
    input$file
  })
  
  output$idchoices = renderUI({
    if(is.null(Maindata$data )){return()}
    selectInput("ID", label = "ID", choices = unique(Maindata$data $ID))
  })
  
  output$threshold = renderUI({
    if(is.null(Maindata$data )){return()}
    sliderInput("threshold", label = "Choose your threshold", 
                min = 1,max = 1000,value = 100,step = 1)
  })
  
  output$daychoices = renderUI({
    if(is.null(Maindata$data )){return()}
    day.dat = filter(Maindata$data ,ID%in%input$ID)
    selectInput("Day", label = "Day", choices = sort(unique(day.dat$Day)))
  })
  
# summary
  output$sum = renderTable({
    if(is.null(Maindata$data )){return()}
    accelsummary(x=selected(), w= flag.selected(),h=input$threshold)
  })
  output$summarytitle = renderText({
    if(is.null(Maindata$data )){return()}
    paste("Summary for Subject", input$ID, "on Day", input$Day)
  })
# download
  output$downloadflagbutton <- downloadHandler(
    filename = function() {paste0('flag_data.csv') },
    content = function(con) { write.csv(flag.all(), con) }
  )
  
  # output$downloadflagbutton = renderUI({
  #   if(is.null(Maindata$data )){return()}
  #   downloadButton('downloadflag',label = "Download WNW Flag")
  # })
  
  # download summary all data
  output$download.summary.button <- downloadHandler(
    filename = function() {paste0('Summary_data.csv') },
    content = function(con) {
      write.csv(accelsummary_data(data = Maindata$data , 
                                  wear = flag.all(), 
                                  h=input$threshold), con)
    }
  )
  # output$download.summary.button = renderUI({
  #   if(is.null(Maindata$data )){return()}
  #   downloadButton('download.summary',label = "Download Summary")
  # })
  
# plot  
  output$plot <- renderPlot({
    if(is.null(Maindata$data )){return()}
    flag = WNW_data(Maindata$data )
    activity_profile(data = Maindata$data , wear = flag,
                     id = input$ID, day = input$Day,h = input$threshold)
  })
  
  # output$contents = renderUI({
  #   if(is.null(Maindata$data )){return()}
  #   else
  #     tabsetPanel(tabPanel("About file",tableOutput("filedf")),
  #                 tabPanel("Summary",tableOutput("sum")),
  #                 tabPanel("Plot", plotOutput("plot")))
  # })
  # output$fitbitkey = renderUI({
  #   if(is.null(Maindata$data )){return()}
  #   textInput("key", label = "Fitbit Key",)
  # })
  
  output$fitbitdata<- downloadHandler(
    filename = function() {
        paste0('fitbit', input$subid,'_Day',input$date, '.csv')
    },
    content = function(con) {
      FITBIT_KEY = input$key
      FITBIT_SECRET = input$secret
      date = input$date
      subname = input$subid
      
      token = oauth_token(key = FITBIT_KEY, secret = FITBIT_SECRET)
      df = get_activity_intraday_time_series(token, "steps", date=date, detail_level="1min")
      df = as.data.frame(t(df[,2]))
      names(df) = paste0("MIN",c(1:1440))
      dt = weekdays(as.Date(date))
      if(dt == "Monday"){dt = 2}
      if(dt == "Tuesday"){dt = 3}
      if(dt == "Wednesday"){dt = 4}
      if(dt == "Thursday"){dt = 5}
      if(dt == "Friday"){dt = 6}
      if(dt == "Saturday"){dt = 7}
      if(dt == "Sunday"){dt = 1}
      
      idday = data.frame(ID = subname, Day = dt)
      out = cbind(idday,df)
      write.csv(out, con,row.names = F)
    }
  )
  
  out = reactive({
    FITBIT_KEY = input$key
    FITBIT_SECRET = input$secret
    date = input$date
    subname = input$subid
    
    token = oauth_token(key = FITBIT_KEY, secret = FITBIT_SECRET)
    df = get_activity_intraday_time_series(token, "steps", date=date, detail_level="1min")
    df = as.data.frame(t(df[,2]))
    names(df) = paste0("MIN",c(1:1440))
    dt = weekdays(as.Date(date))
    if(dt == "Monday"){dt = 2}
    if(dt == "Tuesday"){dt = 3}
    if(dt == "Wednesday"){dt = 4}
    if(dt == "Thursday"){dt = 5}
    if(dt == "Friday"){dt = 6}
    if(dt == "Saturday"){dt = 7}
    if(dt == "Sunday"){dt = 1}
    
    idday = data.frame(ID = subname, Day = dt)
    cbind(idday,df)
    
  })
  
  
  
  observeEvent(input$combine,{
    Maindata$data <- rbind(Maindata$data,out())
  })
  
  observeEvent(input$uploadact,{
    write.csv(Maindata$data, "act_all.csv", row.names = FALSE)
    token = drop_auth(new_user = T)
    drop_upload("act_all.csv")
  })

  observeEvent(input$uploadflag,{
    write.csv(flag.all(), "flag_all.csv", row.names = FALSE)
    token = drop_auth(new_user = T)
    drop_upload("flag_all.csv")
  })
  
  observeEvent(input$uploadsummary,{
    write.csv(accelsummary_data(data = Maindata$data , 
                                wear = flag.all(), 
                                h=input$threshold), 
              "summary_all.csv", row.names = FALSE)
    token = drop_auth(new_user = T)
    drop_upload("summary_all.csv")
  })
  
})
