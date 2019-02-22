clear all;close all;clc

%% Data 
data=xlsread('Data_CLI.xlsx','Data','A1:C252');
indicador=data(:,1)<data(:,2);
ipc=xlsread('Data_CLI.xlsx','Data','L1;L252');
