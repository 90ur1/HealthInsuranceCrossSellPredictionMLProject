library(shiny)
library(ggplot2) # plotting lib
library(gridExtra) # arrange grids
library(mice)  # data imputing
library(corrplot) # correlation matrix plotting/printing
library(pROC) # to measure model performance
library(png) # deals with png file measurements
library(knitr) #
library(xtable) # tabular data formatting 
library(caret) # predictive models
library(dplyr)
library(reshape2)
library(arules)
library(randomForest) # classification algorithm
library(ggthemes) # visualization
library(scales) # visualization
library(smotefamily)
library(caret)
library(Hmisc)
library(e1071)

#view/control layer
shinyServer(function(input, output) {
    
    #bai
    output$summary <- renderPrint({
        dataset <- userDataSet()
    })
    output$inputDataTable_1<-renderTable({
        convertFromValtoLabel(getInputAsDataFrame(input))%>%select(Age, Policy_Sales_Channel, Gender, Region_Code, Vehicle_Age)
    })
    output$inputDataTable_2<-renderTable({
        convertFromValtoLabel(getInputAsDataFrame(input))%>%select(Annual_Premium, Previously_Insured, Vehicle_Damage, Vintage)
    })
    output$inputDataTable_3<-renderTable({
        convertFromValtoLabel(getInputAsDataFrame(input))%>%select(Age, Policy_Sales_Channel, Gender, Region_Code, Vehicle_Age)
    })
    output$inputDataTable_4<-renderTable({
        convertFromValtoLabel(getInputAsDataFrame(input))%>%select(Annual_Premium, Previously_Insured, Vehicle_Damage, Vintage)
    })
    output$predictionResultByNaiveBayesian<-renderText({
        afterPreprocessedData=getInputDatasetForNaiveBayesian(input)
        #afterPreprocessedData = preprocessingForNaiveBayesian(beforePreprocessed)
        predictedResult=predict(naiveBayesianModel, afterPreprocessedData)
        predictedResult=ifelse(predictedResult==0, "Probably Not Interested", "Probably Interested")
        return(predictedResult)
    })
    
    output$predictionResultByGLM<-renderText({
        afterPreprocessedData=getInputDatasetForGLM(input)
        #afterPreprocessedData = preprocessingForNaiveBayesian(beforePreprocessed)
        predictedResult=predict(glmModel, afterPreprocessedData)
        tempResult = ifelse(predictedResult >0.5, "Probably Interested", "Probably Not Interested")
        #        predictedResult=ifelse(predictedResult==0, "Probably Not Interested", "Probably Interested")
        return(tempResult)
    })
})
#data control
getInputDatasetForNaiveBayesian<-function(input){
    result = preprocessingForNaiveBayesian(getInputAsDataFrame(input))
    return(result)
}
getInputDatasetForGLM<-function(input){
    result = preprocessingForGLM(getInputAsDataFrame(input))
    return(result)
}

getInputAsDataFrame<-function(x){
    input = x
    tempResult = data.frame(cbind("Age"=input$Age,"Gender"=input$Gender, "Region_Code"=input$Region_Code, "Vehicle_Age"=input$Vehicle_Age, "Vintage"=input$Vintage, "Annual_Premium"=input$Annual_Premium, "Policy_Sales_Channel"=input$Policy_Sales_Channel, 
                                  "Previously_Insured"=input$Previously_Insured, "Vehicle_Damage"=input$Vehicle_Damage))
    return(tempResult)
}

convertFromValtoLabel<-function(inputDt=x){
    tempResult = inputDt
    tempResult$Gender=ifelse(tempResult$Gender==0, "Female", "Male")
    tempResult$Vintage=as.integer(tempResult$Vintage)
    tempResult$Previously_Insured=ifelse(tempResult$Previously_Insured==0, "No", "Yes")
    tempResult$Vehicle_Damage=ifelse(tempResult$Vehicle_Damage==0, "No", "Yes")
    return(tempResult)
}

preprocessingForNaiveBayesian <- function(x){
    preprocessedData=x
    preprocessedData$Gender=as.factor(preprocessedData$Gender)
    #preprocessedData$Driving_License=as.factor(preprocessedData$Driving_License)
    preprocessedData$Region_Code=as.character(preprocessedData$Region_Code)
    preprocessedData$Previously_Insured=as.factor(preprocessedData$Previously_Insured)
    preprocessedData$Vehicle_Damage=as.factor(preprocessedData$Vehicle_Damage)
    preprocessedData$Policy_Sales_Channel=as.character(preprocessedData$Policy_Sales_Channel)
    preprocessedData$Vehicle_Age=as.factor(preprocessedData$Vehicle_Age)
    preprocessedData$Annual_Premium=as.factor(preprocessedData$Annual_Premium)
    preprocessedData$Age=as.factor(preprocessedData$Age)
    preprocessedData$Vintage=as.factor(preprocessedData$Vintage)
    return(preprocessedData)
}

preprocessingForGLM<-function(data){
    data$Age = getScaleForGLM(as.numeric(data$Age))
    data$Gender = as.numeric(ifelse(data$Gender=="0", 2, 1))
    data$Vehicle_Age = as.numeric(ifelse(data$Vehicle_Age=="> 2 Years", 3, ifelse(
        data$Vehicle_Age=="1-2 Year", 2, 1)))
    data$Vehicle_Damage = as.numeric(ifelse(data$Vehicle_Damage=="0", 2, 1))
    data$Previously_Insured = as.numeric(ifelse(data$Previously_Insured=="0", 1, 2))
    idx = match((data$Region_Code),c('15','28','29','30','41','46','50', '8'))
    if(is.na(idx)){
        data$Region_Code = as.numeric(9)
    } else {
        data$Region_Code = as.numeric(idx)
    }
    indx <- sapply(data[], is.factor)
    data[indx] <- lapply(data[indx], function(x) as.numeric(as.factor(x)))
    data$Driving_License = data%>%select(-Driving_License)
    data$Annual_Premium = data%>%select(-Annual_Premium)
    data$Policy_Sales_Channel = data%>%select(-Policy_Sales_Channel)
    data$Vintage = data%>%select(-Vintage)
    return(data)
}

getScaleForGLM <- function(y) (y - 38.51706) /14.84503

#model Loading
naiveBayesianModel <- readRDS("naiveModel.rds")
glmModel <- readRDS("glmModel.rds")