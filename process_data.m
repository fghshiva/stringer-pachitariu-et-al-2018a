clear all

% you should change this to your local data paths
dataroot = '/media/carsen/DATA2/grive/10krecordings/spontData';
%dataroot = 'D:/grive/10krecordings/spontData';

% give a local folder for saving intermediate data (3GB max)
matroot = '/media/carsen/DATA2/grive/10krecordings/spontResults';
%matroot = 'D:/grive/10krecordings/spontResults';

mkdir(matroot)

% do you have a GPU? if not set to 0
useGPU = 1;

% should be in github folder
addpath(genpath('.'));

% also download rastermap
% https://github.com/MouseLand/rastermap/
addpath('/media/carsen/DATA2/Github/rastermap/matlab/');
%addpath('C:\Users\carse\github\rastermap\matlab');

dex = 2; % second dataset as example dataset

%% this will perform analyses and save output for figures

%% run PC analysis
pcAnalysis(dataroot,matroot, useGPU, dex);

%% run rastermap and determine distance-dependence of clusters
smooth1Dclusters(dataroot,matroot,useGPU, dex);

%% predict PCs from each other
peerPC_cov(dataroot, matroot, useGPU, dex);

%% run behavioral analyses
predictPCsFromAllBeh(dataroot,matroot,useGPU);
quantifyBehavior(dataroot,matroot, dex);

%% time delay analysis (panel 4K)
% we used nseed = 10 in the paper - this will be a bit slow
faceTimelagsToPCs(dataroot,matroot,useGPU);

%% run analysis for stim-spont
sharedVariance(dataroot, matroot, useGPU);
faceStatistics(dataroot, matroot);
stimfaceVariance(dataroot,matroot,useGPU);

%% ----------- supplementary figure analyses --------------

%% varying number of neurons for SVCA and behavior predictions
incNeurFacePred(dataroot, matroot, useGPU);

%% varying time bin
% using single-plane 30Hz recordings
% (you'll have to download new data from figshare)
timebinAnalysis_30hz(dataroot, matroot, useGPU);

%% single neuron analyses (instead of predicting SVCs)

% peer prediction for neurons is pretty slow 
% (because there are different peers for each neuron)
% (I've put the mat file in the folder if you want to use it 'PCApred.mat')
peerExcludeNeighbors(dataroot,matroot,useGPU);

% behavioral prediction
predictNeuronsFromAllBeh(dataroot,matroot,useGPU, dex);

% behavioral predictions at different time delays
faceTimelags(dataroot,matroot,useGPU);

% correlation of neurons with behaviors at different depths
arousalDepths(dataroot, matroot)

% returns face prediction of neuron and its position
predictNeuronsFromFacePositions(dataroot,matroot);

%% stim-spont controls

% using drifting grating responses
% (you'll have to download new data from figshare)
sharedVariance_ori32(dataroot, matroot, useGPU);
faceStatistics_ori32(dataroot, matroot);

% ephys stim-spont
% (data not yet available)
stimspontcorr_ephys(matroot);
