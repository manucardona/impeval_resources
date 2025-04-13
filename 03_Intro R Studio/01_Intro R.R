#########################################################
###   Introducción al análisis de datos en R Studio   ###
###                                                   ###
###   Laboratorio R Studio. Evaluación de PP          ###
###   Autor: Manuel Cardona Arias                     ###
###          <jose.cardona@alumnos.cide.edu           ###
###   Creado: 24/Septiembre/2020                      ###
#########################################################

rm(list = ls()) # to clean the workspace

# *****************************************************************************
#### 01 Statistical analysis ####
# *****************************************************************************

# Statistical analysis in five steps:
#   1. Raw data: the data as it comes in. Reading such files into an R data.frame
#      is either difficult or impossible without some sort of preprocessing.
#
#   2. Technically correct data: In this state, dara can be read into an R data.frame
#      with correct names, types and lables, without further trouble.
#
#   3. Consistent data: is the state where dara is ready for statistical inference.
#
#   4. Statistical results: results have been produced.
#
#   5. Formatted output: ready to be included in final reports or publications.


# *****************************************************************************
#### 02 General background in R ####
# *****************************************************************************

# Your most valuable resources: The Book of R (Davies, 2016) & Google :D 

# Navigating through R Sturdio ------

#The R prompt that indicates R is ready and awaiting a comand is a > symbol.
options(prompt="R> ")				#You may change the R prompt.

# For executing an R script, you select all the text and Ctrl+R

# Comments are denoted by the # symbol

# Comments can also appear after valid commands
1+1 #This works out the result of one plus one

# Working directory
getwd()                                   #Get working directory
setwd("C:/Users/José Manuel/Documents/IPA/Poverty Probability Index/R Sessions")
#Set working directory

#Installing and loading R Packages.
library("MASS")
install.packages("ks")

#Updating packages
update.packages("ks")

#When you don´t have any idea of what you are doing:
?mean

#If you are unsure of the precise name of the desired function, you can search
#the documentation across all installed packages using a double ??.
??"mean"

# SAVING WORK AND EXITING R
#You may press ctrl+S to save a Script
#You may press ctrl+O to open an existing Script							
#q()

# *****************************************************************************
#### 03 Numerics, arithmetic, assignment, and vectors ####
# *****************************************************************************

# R for basic math -----

#You can perform addition, subtraction, multiplication, and division. You can
#create exponents and control the order of calculations.

2+3
14/6
14/6+5
14/(6+5)
3^2
2^3

#You can find the square root of any non-negative number with the sqrt function.
sqrt(x=9)
sqrt(5.311)

#You can, for sure, compute more difficult expressions.
2^(2+1)-4+64^((-2)^(2.25-1/4))
(0.44*(1-0.44)/34)^(1/2)

#You'll often read about performing a log transformation of certain data.
#This refers to rescaling numbers according to the logarithm.
log(x=243, base=3)

  #Both x and the base must be positive. 
  log(x=243, base=3)

  #The log of any number x when the base is equal to x is 1.
  log(x=243, base=243)
  
  #The log of x=1 is always 0, regardless of the base. 
  log(x=1, base=3)
  log(x=1, base=243)
  
#The exponential function represents the inverse of the natural log.
exp(x=3)

log(x=20.08554)


# Math in R: Exercise --------

#1. What is the result of (6a + 42) / (3^(4.2-3.62)), when a=2.3.

#2. Which of the following squares negative 4 and adds 2 to the result?
  #i.   (-4)^2+2
  #ii.  -4^2+2
  #iii. (-4)^(2+2)
  #iv.  -4^(2+2)

#3. Using R, how would you calculate the square root of half of the
#   average of the numbers 25.2, 15, 16.44, 15.3, and 18.6?

#4. Find log_e 0.3.

#5. Compute the exponential transform of your answer to the previous question.


# Assigning objects -----

#If you want to save the results and perform further operations, 
#you need to assign somke output to an "object".

#You can specify an assignment in R in two ways: using arrow notation
  # <-
#or using a single equal sign
  # =. 

x <- -5
x

x = x+1 #This overwrites the previous value of x
x

mynumber = 45.2

y <- mynumber*x
y

ls() #Shows all the objects that are stored in the local memory.

# Assignment: Exercise --------

#a. Create an object that stores the value 3^2 × 4^(1/8).

#b. Overwrite your object from previous question by itself divided by
#   2.33. Print the result to the console.

#c. Create a new object with the value of -8.2 x 10^(-13).

#d. Print directly to the console the result of multiplying (b) by (c).

# Vectors --------
