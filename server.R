#c2

library(shiny)
library(car)
library(datasets)
library(ggmap)
library(maps)
library(ggplot2)
data("Anscombe")
data("USArrests")
data("States")

## Data Pre-Processing - Align the States/rownames in all datasets
rownames(Anscombe)[24]<-"DI"
Anscombe=Anscombe[order(rownames(Anscombe)),]
USArrests["District of Columbia",]<-NA
USArrests=USArrests[order(rownames(USArrests)),]

## Rename Columns
colnames(Anscombe)=c("Per capita education expenditures in $","Per capita income in $","Proportion <18, per Thousand","Proportion urban, per Thousand")
colnames(USArrests)=c("Murder arrests (per 100,000)","Assault arrests (per 100,000)","% urban population","Rape arrests (per 100,000)")
colnames(States)=c("Region","Population in Thousands","SATV - Avg score in the state on the verbal component of the SAT.","SATM - Average score in the state on the math component of the SAT.","Percentage of students in the state who took the SAT exam.","State spending on public education, in $1000s per student.","Average teacher's salary in the state, in $1000s.")

shinyServer(function(input, output) {
        ## Get the requested dataset
        datasetInput <- reactive({
                switch(input$dataset,"Education and Related Statistics" = States,"Public-School Expenditures" = Anscombe,"Violent Crime Rates" = USArrests)
        })

        ## Cascading Input filter for Fill-variable
        output$control <- renderUI({
                radioButtons("variable", "Select Fill Variable for the U.S. Map:",choices = names(datasetInput()),selected=names(datasetInput())[1])
        })

        ## Display Title
        output$Title<-renderText({
                paste(input$dataset," - Analysis by ",input$variable)
        })


        ## Data regarding U.S States plot
        StatesMap=map_data("state")

        ## Unique States - Align the rownames across all 4 datasets
        StatesMap$state=StatesMap$region
        StatesMap=StatesMap[,-5]
        StatesRow=unique(StatesMap$state)
        StatesRow=c(StatesRow,"alaska","hawaii")
        StatesRow=sort(StatesRow)

        ## Setup the U.S. Map - Fill by selected variable - Server Calculation -1
        output$Map<-renderPlot({

                ## Get States corresponding to Brushed data
                brushed_data=StatesRow

                ## Data regarding selected states and dataset
                dataset <- datasetInput()
                Df<-dataset[which(StatesRow %in% brushed_data),]
                Df<-cbind(state=tolower(brushed_data),Df)


                ## Merge map data and selected dataset
                StatesMap=merge(StatesMap,Df,by="state")
                index=which(names(StatesMap)==input$variable)
                if(input$variable!="Region")
                        ggplot(StatesMap,aes(x=long,y=lat,group=group,fill=StatesMap[,index]))+geom_polygon(color="black")+scale_fill_gradient(name=names(StatesMap)[index],low="white",high="red")+coord_cartesian()+scale_x_continuous(breaks = NULL) +scale_y_continuous(breaks = NULL) +labs(x = "", y = "")+theme(panel.background = element_blank())
                else
                        ggplot(StatesMap,aes(x=long,y=lat,group=group,fill=StatesMap[,index]))+geom_polygon(color="black")+coord_cartesian()+ labs(fill = "Region") +scale_x_continuous(breaks = NULL) +scale_y_continuous(breaks = NULL) +labs(x = "", y = "")+theme(panel.background = element_blank())
                })
        ## Calculate and display mean of Fill variable - Sever Calculation - 2
        output$Mean<-renderText({
                ## Get States corresponding to Brushed data
                brushed_data<-brushedPoints(StatesMap,input$brush1)
                brushed_data<-unique(brushed_data$state)
                if(length(brushed_data)==0)
                        brushed_data=StatesRow

                ## Calculate mean of Fill variable for the selected states
                dataset <- datasetInput()
                Df<-dataset[which(StatesRow %in% brushed_data),]
                Df<-cbind(STATES_SELECTED=toupper(brushed_data),Df)
                index=which(names(Df)==input$variable)
                if(input$variable!="Region")
                        paste(" The Mean of ",input$variable," for the selected states is: ",round(mean(Df[,index],na.rm=TRUE),2))
                else
                        ""
        })


        ## Display Output
        output$view <- renderTable({

                ## Get States corresponding to Brushed data
                brushed_data<-brushedPoints(StatesMap,input$brush1)
                brushed_data<-unique(brushed_data$state)
                if(length(brushed_data)==0)
                        brushed_data=StatesRow

                ## Dispay data regarding selected states and dataset - Server Calculation-3
                dataset <- datasetInput()
                Df<-dataset[which(StatesRow %in% brushed_data),]
                Df<-cbind(STATES_SELECTED=toupper(brushed_data),Df)
                na.omit(Df)

        })
        })
