# actcoolshiny
##1. Targeted Users
This app is a handy exploratory tool for researchers who want to use accelerometery data, to be more specific, minute level activity count data. We required the data to be stored in a $n \times (2+ 1440)$ matrix, where n is each subject-day, and the first two colums are ID and date, and the following are 1440 minutes.
After users supply the data in the correct format, the app will create wear/nonwear flags, calculate activity summaries, and created daily profile plots. Meanwhile, users can choose to donate his/her own fitbit data to be part of the dataset. 

##2. Where is code
Backend code is in the package "actcool" which can be downloaded by the following line
```{r,eval=FALSE}
devtools::install_github("junruidi/actcool")
```
Code for the shiny app can be found at 
https://github.com/junruidi/actcoolshiny .
The shiny app is also hosted at 
https://jhubiostatistics.shinyapps.io/actcoolshiny/.
Please notice that, due to the interactive functionality of dropbox and fitbit api (rdrop2 and fitbitr), these two api's cannot be ran directly from shynyapps.io. But from a local PC, it works well.

##3. Tutorial for the shiny app
1. Upload the csv file of the minute level activity count data.
2. Once uploaded, the weaer/nonwear flag (same dimension as the acitivity count data) will be created in the back end.
3. By selecting subject ID and date, summaries can be seen, and the profile plot can be seen.
4. Users can download all resulted datasets to local, or send them to the dropbox.
5. By providing fitbit tokens, user can donate his/her fitbit record to be part of the activity count dataset.
(Note: 4-5 don't work on the shiny.io. If you would like to use it ,please download the source code for the app and run it locally.)

##4. Example data location
The exmaple data is stored in the following github repository
https://github.com/junruidi/actcoolshiny, with name "act.csv".
