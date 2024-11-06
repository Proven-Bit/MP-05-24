SMR_Plant.m is the main script that will make the LCOM values for 5 different setups of feedstock for the Methanol production
LCOM_1 : Blended bio and fossil 50/50 
LCOM_2 : Fossil feedstock only
LCOM_3 : Bio feedstock only
LCOM_4 : 50 % Biofeedstock 50 % Green Hydrogen with CO2 feedstock
LCOM_5 : Green Hydrogen with CO2 feedstock only

this script will use the function saveDataToCSV.m to save the settings and the calculated LCOM from this "assumptions"

Data_Analytics will read in the data recorded in the CSV created and do analytics based on this.

Markets folder includes a scripts that plots the market data for methanol price for report.
