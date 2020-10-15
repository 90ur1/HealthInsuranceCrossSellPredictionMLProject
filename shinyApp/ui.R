#install.packages("shinythemes")
library(shiny)
library(shinythemes)

#define basic constant/values list
#gender panel
genderHeader<-"Gender of the customer"
genderTypeList <- list("Female" = 0, "Male" = 1)
#age panel
ageHeader<-"Age of the customer"
#region panel
regionHeader<-"Unique code for the region of the customer (0 to 52)"
regionCodeList <-  seq(0, 52, by=1)
#previously insured panel
prevInsurHeader<-"Does customer already have a Vehicle Insurance?"
prevInsuredAnswerList <- list("Yes" = 1, "No" = 0)
#Vehicle Age
veAgeHeader<-"Age of the Vehicle"
veAgeAnswerList<-list("less than 1 year"="< 1 Year", "between 1 and 2 year"="1-2 Year", "more than 2 years"="> 2 Years")
#Vehicle_Damage
veDamagedHeader<-"Did customer's vehicle get damaged in the past?"
veDamagedAnswerList<-list("Yes"=1, "No"=0)
#Annual_Premium
annualPremiumHeader<-"The amount customer needs to pay as premium in the year"
annualPremiumAnswerList<-list()
#Policy_Sales_Channel
policySalesChannelHeader<-"The channel of outreaching to the customer (1 to 163)"
policySalesChannelAnswerList<-seq(1, 163, by=1)
#Vintage
vintageHeader<-"Number of Days, Customer has been associated with the current company - Vintage (more than 300 days, please select max)"


#view layer
shinyUI(fluidPage(
    
    #input elements
    theme = shinytheme("flatly"),
    # Application title
    titlePanel("Health Insurance Cross Sell Predictor"),
    
    #Annual Premium
    sidebarPanel(
        # fileInput('file1', 'Choose CSV File', 
        #           accept=c('text/csv', 
        #                    'text/comma-separated-values,text/plain', 
        #                    '.csv')) 
        # ,
        #Driving Licence
        radioButtons("Driving_Licence", label = h3("Driving Licence"),
                     choices = c("Yes"=1, "No"=0), 
                     selected = 1),
        #Gender
        radioButtons("Gender", label = h3(genderHeader),
                     choices = genderTypeList, 
                     selected = 0),
        #Age
        numericInput("Age", label = h3(ageHeader), value = 20, min=20, max=100),
        #Region Code
        selectInput("Region_Code", label = h3(regionHeader), 
                    choices = regionCodeList, 
                    selected = 0),
        #Previously Insured
        radioButtons("Previously_Insured", label = h3(prevInsurHeader),
                     choices = prevInsuredAnswerList, 
                     selected = 1),  
        #vintage
        column(12,
               sliderInput("Vintage", label = h3(vintageHeader), min = 0, 
                           max = 300, value = 150)
        ),
        #Vehicle_Age
        selectInput("Vehicle_Age", label = h3(veAgeHeader), 
                    choices = veAgeAnswerList, 
                    selected = "< 1 Year"),
        #Vehicle_Damage
        radioButtons("Vehicle_Damage", label = h3(veDamagedHeader), 
                    choices = veDamagedAnswerList, 
                    selected = 1),
       
        #Annual_Premium
        numericInput("Annual_Premium", label = h3(annualPremiumHeader), value = 30000, min=0, max=60000),
        
        #Policy_Sales_Channel
        selectInput("Policy_Sales_Channel", label = h3(policySalesChannelHeader), 
                    choices = policySalesChannelAnswerList, 
                    selected = 1),
        submitButton("Submit")
    ),
    mainPanel(
        tabsetPanel(
            tabPanel("Generalized linear model (GLM)",
                     h2("Prediction by GLM"),
                     h4("Input Data"),
                     tableOutput("inputDataTable_3"),
                     tableOutput("inputDataTable_4"),
                     h4("Prediction"),
                     verbatimTextOutput("predictionResultByGLM")
            )
            # ,
            # tabPanel("Naive-Bayesian Model",
            #          # Output: Verbatim text for data summary ----
            #          h2("Prediction by Naive-Bayesian Model"),
            #          h4("Input Data"),
            #          tableOutput("inputDataTable_1"),
            #          tableOutput("inputDataTable_2"),
            #          h4("Prediction"),
            #          verbatimTextOutput("predictionResultByNaiveBayesian")
            # )
            # , 
            # tabPanel("temp",
            #          h2("Prediction by Sample"),
            #          DT::dataTableOutput('contents'),
            #          verbatimTextOutput("predictionListOfInputByGLM")
            # )
        )
        
        
    )
))
