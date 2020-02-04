Presentation
========================================================
author: alt-data
date: 02/04/2020
autosize: true


Main Features
========================================================
The Shiny Application on **U.S. States Analysis** has the following main features -
<small>
- **Interactive States Selection** - Allows users to select a group of U.S. states from the U.S. map interactively with the help of a Shiny attribute - **Brush**. The Analysis then filters as per the selected states.
- **3 in 1 Datasets Analysis** - Allows users to further select a dataset out of 3 available datasets and perform **Exploaratory Data Analysis** in the areas of **Education and Related Statistics** - States dataset {car package}, **Public-School Expenditures** - Anscombe dataset {car package} and **Violent Crime Rates by US States** - USArrests dataset {datasets package}
- **Cascade Input Filter Selection** - Based on the dataset selected, it allows user to further select a **Fill variable** in order to fill and analyze the U.S. states by that variable.</small>



The App
========================================================
![The U.S. States Analysis App - Snapshot](example.png)

<h2>Embedded R code - A runnable example</h2>
<small>
**A runnable example of server calculation from the Shiny Application is given on the next page. We have assumed that the user has selected the following set of input values from the UI**- The USArrests dataset, The Fill Variable - Murder arrests (per 100,000) and The U.S. States - IDAHO, MONTANA and WYOMING.</small>


Embedded R code - A runnable example (contd.)
========================================================
<font size="4">

```r
library(ggplot2);library(datasets)
data("USArrests")
## Data Pre-Processing
USArrests["District of Columbia",]<-NA
USArrests=USArrests[order(rownames(USArrests)),]
colnames(USArrests)=c("Murder arrests (per 100,000)","Assault arrests (per 100,000)","Percent urban population","Rape arrests (per 100,000)")## Rename the columns
variable="Murder arrests (per 100,000)" ##Input Fill Variable
brushed_data=c("idaho","montana","wyoming") ##Selected U.S. States
dataset=USArrests
## Data regarding U.S States plot and Align the rownames across all 4 datasets
StatesMap=map_data("state")
StatesMap$state=StatesMap$region
StatesMap=StatesMap[,-5]
StatesRow=unique(StatesMap$state)
StatesRow=c(StatesRow,"alaska","hawaii")
StatesRow=sort(StatesRow)
## Calculate mean of Fill variable for the selected states
Df<-dataset[which(StatesRow %in% brushed_data),]
Df<-cbind(STATES_SELECTED=toupper(brushed_data),Df)
index=which(names(Df)==variable)
paste(" The Mean of ",variable," for the selected states is: ",round(mean(Df[,index],na.rm=TRUE),2))
```

```
[1] " The Mean of  Murder arrests (per 100,000)  for the selected states is:  5.13"
```

```r
## Dispay data regarding selected states and dataset
knitr::kable(na.omit(Df),row.names=FALSE)
```



|STATES_SELECTED | Murder arrests (per 100,000)| Assault arrests (per 100,000)| Percent urban population| Rape arrests (per 100,000)|
|:---------------|----------------------------:|-----------------------------:|------------------------:|--------------------------:|
|IDAHO           |                          2.6|                           120|                       54|                       14.2|
|MONTANA         |                          6.0|                           109|                       53|                       16.4|
|WYOMING         |                          6.8|                           161|                       60|                       15.6|
</font>

code example
========================================================
<font size="4">



```
Error in parse(text = x, srcfile = src) : <text>:10:17: unexpected 'else'
9: r="black")+scale_fill_gradient(name=names(StatesMap)[index],low="white",high="red")+coord_cartesian()+scale_x_continuous(breaks = NULL) +scale_y_continuous(breaks = NULL) +labs(x = "", y = "")
10:                 else
                    ^
```
