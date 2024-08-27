%% YOU CHOOSE PARAMETERS
clc
clear all
%%
events = {'Ictal', 'Inter_ictal0'};
electrodes = {'\T4', '\T6', '\F10', '\CP6', '\O2'};
root = 'C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Features\Sem2\CWT3\Patient 0';
files = {'\PN00_1', '\PN00_2', '\PN00_3','\PN00_4','\PN00_5'};
fileLocations1 = getLocs(root, files, electrodes, events);
electrodes2 = {'\T3', '\T5', '\F9', '\CP5'};
root2 = 'C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Features\Sem2\CWT4\';
files2 = {'\PN13_1', '\PN13_3'};
fileLocations2 = getLocs(root2, files2, electrodes2, events);
electrodes3 = {'\T3', '\T5', '\F9', '\O2','\CP5'};
root3 = 'C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Features\Sem2\CWT4\';
files3 = {'\PN05_2', '\PN05_4'};
fileLocations3 = getLocs(root3, files3, electrodes3, events);
root4 = 'C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Features\Sem2\CWT4\';
files4 = {'\PN16_1', '\PN16_2'};
fileLocations4 = getLocs(root4, files4, electrodes3, events);
fileLocations = [fileLocations1, fileLocations2, fileLocations3, fileLocations4];
%% GROUPING IMAGE DATA
clc
allImages = imageDatastore(fileLocations, ...
   "IncludeSubfolders",true, ...
   "LabelSource",'foldernames');
%% RATIO BETWEEN SEIZURE / NO SEIZURE DATA
T = countEachLabel(allImages);
ns_to_s = T{2,2} / T{1,2}
% SPLITTING EVENLY
numIctal = T{1,2};
imdsS = splitEachLabel(allImages, numIctal, 'randomized', "Include",'Ictal');
imdsNS = splitEachLabel(allImages,(ns_to_s^-1)*round(ns_to_s),'randomized','Exclude','Ictal');
%%
subds1 = partition(imdsNS,5,1);
subds2 = partition(imdsNS,5,2);
subds3 = partition(imdsNS,5,3);
subds4 = partition(imdsNS,5,4);
subds = {subds1, subds2, subds3, subds4};
%%
%%
imds1 = imageDatastore(cat(1,imdsS.Files,subds{1}.Files));
imds1.Labels = cat(1,imdsS.Labels,subds{1}.Labels);
imds2 = imageDatastore(cat(1,imdsS.Files,subds{2}.Files));
imds2.Labels = cat(1,imdsS.Labels,subds{2}.Labels);
imds3 = imageDatastore(cat(1,imdsS.Files,subds{3}.Files));
imds3.Labels = cat(1,imdsS.Labels,subds{3}.Labels);
imds4 = imageDatastore(cat(1,imdsS.Files,subds{4}.Files));
imds4.Labels = cat(1,imdsS.Labels,subds{4}.Labels);
imds = {imds1, imds2, imds3, imds4};
%%
% TRAIN TEST SPLIT
imgsTrain={};
imgsValidation={};
for i = 1:length(imds)
   [imgsTrain{i},imgsValidation{i}] = splitEachLabel(imds{i},0.8,0.2,"randomized");
end
%%
%% TO RESIZE IMAGES
augimgsTrain = augmentedImageDatastore([299 299],imgsTrain);
augimgsValidation = augmentedImageDatastore([299 299],imgsValidation);
%% CALLING CNN
net = vgg16;
lgraph = layerGraph(net);
newDropoutLayer = dropoutLayer(0.65,"Name","new_Dropout");
lgraph = replaceLayer(lgraph,"drop7",newDropoutLayer);
numClasses = numel(categories(imgsTrain{1}.Labels));
newConnectedLayer = fullyConnectedLayer(numClasses,"Name","new_fc", ...
   "WeightLearnRateFactor",2,"BiasLearnRateFactor",2);
lgraph.Layers(end-4:end)
lgraph = replaceLayer(lgraph,"fc8",newConnectedLayer);
newClassLayer = classificationLayer("Name","new_classoutput");
lgraph = replaceLayer(lgraph,"output",newClassLayer);
lgraph.Layers(end-4:end)
   for j = 1:4
      
       miniBatchSize=32;
       valFreq = floor(numel(imgsTrain{j}.Files)/miniBatchSize);
       Epochs = 10;
       valPat =10;
       newDropoutLayer = dropoutLayer(0.65 + .1*j,"Name","new_Dropout");
       lgraph = replaceLayer(lgraph,"new_Dropout",newDropoutLayer);
       options = trainingOptions("sgdm", ...
           LearnRateSchedule = "piecewise",...
           LearnRateDropPeriod =2,...
           LearnRateDropFactor=.5,...
           shuffle="every-epoch",...
           MiniBatchSize=miniBatchSize, ...
           MaxEpochs=Epochs, ...
           InitialLearnRate=(5e-5), ...
           ValidationData=imgsValidation{j}, ...
           ValidationPatience=valPat,...
           ValidationFrequency=valFreq,  ...
           OutputNetwork="best-validation-loss",...
           Verbose=1);
      
       trainedVGG{i}= trainNetwork(imgsTrain{j},lgraph,options);
       lgraph = layerGraph(trainedVGG);
   end
%%
events = {'Ictal', 'Inter_ictal0'};
electrodes= {'\T3', '\T5', '\F9', '\CP5'};
root = 'C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Features\Sem2\CWT4\';
files = {'\PN06_1'};
fileLocations1 = getLocs(root, files, electrodes, events);
testImages2 = imageDatastore(fileLocations1, ...
   "IncludeSubfolders",true, ...
   "LabelSource",'foldernames');
%%
T = countEachLabel(testImages2);
ns_to_s = T{2,2} / T{1,2};
% SPLITTING EVENLY
numIctal = T{1,2};
imdsS = splitEachLabel(testImages2, numIctal, 'randomized', "Include",'Ictal');
imdsNS = splitEachLabel(testImages2,numIctal,'randomized','Exclude','Ictal');
testImages = imageDatastore(cat(1,imdsS.Files,imdsNS.Files));
testImages.Labels = cat(1,imdsS.Labels,imdsNS.Labels);
%% IF NO STACKING
net = trainedVGG{4};
%%
testImages = testImages2;
[YPred, scores] = classify(net, testImages);
accuracy = sum(YPred == testImages.Labels)/numel(testImages.Labels);
disp(accuracy)
%%
hf = figure;
confusionchart(hf,testImages.Labels,YPred,"RowSummary","row-normalized","ColumnSummary","column-normalized")
%% STACKING
trainedNets = trainedVGG;
testImages2 = testImages;
YPred = {};
scores = {};
accuracy = {};
for i = 1:length(trainedNets)
   [YPred{i}, scores{i}] = classify(trainedNets{i}, testImages2);
   accuracy{i} = sum(YPred{i} == testImages2.Labels)/numel(testImages2.Labels);
   disp(accuracy{i})
end
int = {};
ic = {};
A = cell2mat(scores);
for i = 1:3
   int{i} = A(:,(2*i));
   ic{i} = A(:,(2*i-1));
end
inter_score = sum(cell2mat(int),2)';
ictal_score = sum(cell2mat(ic),2)';
YPred2 = categorical;
for j = 1:length(testImages2.Labels)
   if ictal_score(j) > inter_score(j)
       YPred2(j) = 'Ictal';
   else
       YPred2(j) = 'Inter_ictal0';
   end
end
accuracy3 = sum(YPred2' == testImages2.Labels)/numel(testImages2.Labels)
scores = cell2mat({ictal_score',inter_score'});
%% CONFUSION MATRIX
hf = figure;
confusionchart(hf,testImages2.Labels,YPred2,"RowSummary","row-normalized","ColumnSummary","column-normalized")
%%
classNames = trainedVGG{1}.Layers(end).Classes;
roc = rocmetrics(testImages2.Labels,scores2,classNames);
figure
plot(roc)
title("ROC Curve: VGG16")
%% ASSESSING INACCURACIES
figure
%YPred = YPred2';
k = 1;
for i = 1:numel(testImages2.Labels)
   if YPred(i) ~= testImages2.Labels(i)
       subplot(15,15,k)
       file = testImages2.Files{i,1};
       I = imread(testImages2.Files{i,1});
       imshow(I)
       label = YPred(i);
       title(string(label))
       k = k+1;
   else
   end
end
%%
aucVGG
%%
aucVGG4 = roc.AUC;
%%
aucVGG3 = roc.AUC;
aucVGG1 = roc.AUC;
aucVGG2 = roc.AUC;
%% PLOTTING AUC VALUES
figure
bar([aucVGG1; aucVGG2]')
xticklabels(classNames)
legend(["Non-Focal","Focal"],Location="southeast")
title("AUC")
%% MAJORITY VOTING
YPred2 = categorical(true);
for i = 1:length(testImages.Files)
   for j = 1:length(YPred)
       YPred2(i) = mode(YPred{j}(i,1));
   end
end
accuracy2 = sum(YPred2' == testImages.Labels)/numel(testImages.Labels)
%% FUNCTIONS
function folders = getFolders(root)
   s=dir(root);
   idx=~startsWith({s.name},'.') & [s.isdir];
   folders={s(idx).name};
end
function fileLocations = getLocs(root, files, electrodes, events)
k = 1;
for n = 1:length(files)
   file{n} = strcat(root, files{n});
   for i = 1:length(electrodes)
       eFile{i} = strcat(file{n}, electrodes{i});
       for j = 1:length(events)
           fileLocations{k} = fullfile(eFile{i}, events{j});
           k = k+1;
       end
   end
end
end
function retainIctal(i)
for i = 1:length(allImages.Labels)
   if allImages.Labels(i,1) ~= char('Ictal')
       allImages.Labels(i,1)=categorical(erase(string(allImages.Labels(i,1)), (string(allImages.Labels(i,1)))) ...
           + repmat('Non-Ictal', size(allImages.Labels(i,1), 1), 1));
   else
   end
end
End
