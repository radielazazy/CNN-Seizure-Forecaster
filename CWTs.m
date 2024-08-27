clc
clear all
%%
addpath('\Patient Data\Clean_Data\');
tt1 = edfread('PN00-1.ICA4.edf', 'DataRecordOutputType','vector');
tt2 = edfread('PN00-2.IAE.edf', 'DataRecordOutputType','vector');
tt3 = edfread('PN00-3.IAE.edf', 'DataRecordOutputType','vector');
tt4 = edfread('PN00-4.IAE.edf', 'DataRecordOutputType','vector');
tt5 = edfread('PN00-5.IAE.edf', 'DataRecordOutputType','vector');
tt6 = edfread('PN13-1.common.edf', 'DataRecordOutputType','vector');
tt7 = edfread('PN13-3.common.edf', 'DataRecordOutputType','vector');
tt8 = edfread('PN05-2.edf', 'DataRecordOutputType','vector');
tt9 = edfread('PN05-4.common.edf', 'DataRecordOutputType','vector');
%%
% Get Seizure Period in Dataset (please leave quotes)
r1 = '21.11.29'; % Registration Start Time
%skip Resistration End Time
s1 = '23.39.09'; % Seizure Start Time
s2 = '23.40.18'; % Seizure End Time
times(r1, s1, s2)
%%
% Get [Pre, Post]-ictal Bounds (You choose how long pre, post is) in seconds
seizure_start = 8860;
seizure_end = 8929;
length_pre_ictal = 60*30;
length_post_ictal = 60*1;
bounds(length_pre_ictal, length_post_ictal, seizure_start, seizure_end)
%%
% Ordering of Electrodes
%PN00
t_labels_PN = {'T5', 'T3', 'T4', 'T6'};
f_labels_PN = {'FP1', 'FP2', 'F9', 'F7', 'F3', 'FZ', 'F4', 'F8', 'F10', 'FC5', 'FC1', 'FC2', 'FC6'};
c_labels_PN = {'C3', 'CZ', 'C4', 'CP5', 'CP1', 'CP2', 'CP6'};
p_labels_PN00 = {'P3', 'PZ', 'P4'};
o_labels_PN = {'O1', 'O2'};
electrode_array_PN00 = {t_labels_PN, f_labels_PN, c_labels_PN, p_labels_PN00, o_labels_PN};
%PN 5 & 13
t_labels_PN = {'T5', 'T3', 'T4', 'T6'};
f_labels_PN = {'FP1', 'FP2', 'F9' 'F7', 'F3', 'FZ', 'F4', 'F8', 'F10', 'FC5', 'FC1', 'FC2', 'FC6'};
c_labels_PN = {'C3', 'CZ', 'C4', 'CP5', 'CP1', 'CP2', 'CP6'};
p_labels_PN5_13 = {'P9', 'P3', 'PZ', 'P4' 'P10'};
o_labels_PN = {'O1', 'O2'};
electrode_array_PN5_13 = {t_labels_PN, f_labels_PN, c_labels_PN, p_labels_PN5_13, o_labels_PN};
% Modifying data into structure w/ labels and splitting of seizure events`
fs = 512;
%%
PN00_1 = genStructure(tt1, electrode_array_PN00, 843, 1143, 1213, 1813, fs);
PN00_2 = genStructure(tt2, electrode_array_PN00, 920, 1220, 1274, 1874, fs);
PN00_3 = genStructure(tt3, electrode_array_PN00, 465, 765, 825, 1425, fs);
PN00_4 = genStructure(tt4, electrode_array_PN00, 706, 1006, 1080, 1680, fs);
PN00_5 = genStructure(tt5, electrode_array_PN00, 604, 904, 971, 1571, fs);
PN13_1 = genStructure(tt6, electrode_array_PN5_13, 6762, 7062, 7110, 7710, fs);
PN13_3 = genStructure(tt7, electrode_array_PN5_13, 7253, 7553, 7704, 8304, fs);
PN05_2 = genStructure(tt8, electrode_array_PN5_13, 6863, 7163, 7198, 7798, fs);
PN05_4 = genStructure(tt9, electrode_array_PN5_13, 3308, 3608, 3647, 4247, fs);
PN00_Data = {PN00_1,PN00_2,PN00_3,PN00_4,PN00_5};
dataset_labels_PN00 = {'PN00_1','PN00_2','PN00_3','PN00_4','PN00_5'};
Patient0 = overallstructure(PN00_Data,dataset_labels_PN00);
PN13_Data = {PN13_1,PN13_3};
PN05_Data = {PN05_2, PN05_4};
dataset_labels_PN13 = {'PN13_1','PN13_3'};
dataset_labels_PN05 = {'PN05_2', 'PN05_4'};
Patient13 = overallstructure(PN13_Data,dataset_labels_PN13);
Patient5 = overallstructure(PN05_Data,dataset_labels_PN05);
%
Patients = {Patient0,Patient5,Patient13};
Patient_labels = {'Patient 0','Patient 5','Patient 13'};
TrainingData = patient_structure(Patients, Patient_labels);
%
%%
clc
proj = matlab.project.rootProject;
[root, patientFiles, electrodes, seizure_events] = obtainFolders(TrainingData(3));
disp([root, patientFiles, electrodes, seizure_events])
%%
disp(patientFiles)
%% Creating Directory
clc
channel_directory(root, patientFiles, electrodes, seizure_events)
%% Generating Scalograms
clc
%CWT_spawner(TrainingData, root, patient, electrodes)
disp(TrainingData(1).patients(1).files(1).electrode_data)
%%
CWT_spawner_cheap(TrainingData(3).patients, root, patientFiles, electrodes, 1)
function CWT_spawner_cheap(EEGdata, masterFolder,patientFiles,electrodeFolder, percentage_removed)
 for n = 1:length(patientFiles)
   y = patientFiles{n};
   for m = 1:length(electrodeFolder)
       z = electrodeFolder{m};
       M = getMaxima(EEGdata(n).files(m).electrode_data);
       threshold = removeOutliers(M, percentage_removed);
       electrodeScalogram(EEGdata(n).files(m).electrode_data, masterFolder,y,z,threshold)
   end
 end
end
function electrodeScalogram(EEGdata,masterFolder,patientFiles,electrodeFolder,threshold)
imageRoot = fullfile(masterFolder,patientFiles,electrodeFolder);
Fs = 512;
for i = 1:length(EEGdata)
   events = EEGdata(i).events';
   t1 = 1;
   t2 = Fs*10;
   k=0;
   while t2 <= Fs*length(events)
       segment = events(t1:min(t2,length(events)));
       if i == 3
           t1 = t1 + Fs;
           t2 = t2 + Fs;
           k = k + 1;
           if length(segment) > .9*Fs
              
               [~,signalLength] = size(segment);
               fb = cwtfilterbank(SignalLength=signalLength,SamplingFrequency=512, ...
               VoicesPerOctave=12,FrequencyLimits=[2 100], Wavelet='bump');
               cfs = abs(fb.wt(segment));
               norm_cfs = (cfs - min(cfs))./max(threshold);
               powerLimit = (max(max(norm_cfs)));
               im = ind2rgb(round(rescale(cfs,0,255*powerLimit)),jet(128));
               imgLoc = fullfile(imageRoot,char(EEGdata(i).labels));
               imFileName = char(EEGdata(i).labels)+"_"+num2str(k)+".jpg";
               imwrite(imresize(im,[224 224]),fullfile(imgLoc,imFileName));
           end
       else
           t1 = t1 + Fs*10;
           t2 = t2 + Fs*10;
           k = k + 1;
           if length(segment) > 8*Fs
               [~,signalLength] = size(segment);
               fb = cwtfilterbank(SignalLength=signalLength,SamplingFrequency=512, ...
               VoicesPerOctave=12,FrequencyLimits=[2 100], Wavelet='bump');
               cfs = abs(fb.wt(segment));
          
               norm_cfs = (cfs - min(cfs))./max(threshold);
               powerLimit = (max(max(norm_cfs)));
               im = ind2rgb(round(rescale(cfs,0,255*powerLimit)),jet(128));
               imgLoc = fullfile(imageRoot,char(EEGdata(i).labels));
               imFileName = char(EEGdata(i).labels)+"_"+num2str(k)+".jpg";
               imwrite(imresize(im,[224 224]),fullfile(imgLoc,imFileName));
           else
           end
       end
   end
end
end
function CWT_spawner(EEGdata, masterFolder, patientFolder,patientFiles,electrodeFolder)
for i = 1:length(patientFolder)
 x = patientFolder{i};
 for n = 1:length(patientFiles)
   y = patientFiles{n};
   for m = 1:length(electrodeFolder)
       z = electrodeFolder{m};
       electrodeScalogram(EEGdata(i).patients(n).files(m).electrode_data, masterFolder, x,y,z)
   end
 end
end
end
function [root, patientFiles, electrodeFolder, seizure_events] = obtainFolders(EEGdata)
   root = 'C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Features\Sem2\CWT2';
   %patientNum = getlabels(EEGdata);
   patientFiles = getlabels(EEGdata(1).patients);
   electrodeFolder = getlabels(EEGdata(1).patients(1).files);
   seizure_events = getlabels(EEGdata(1).patients(1).files(1).electrode_data);
  
end
function B = getlabels(s)
B = [];
   for i = 1:length(s)
       B{i} = s(i).labels;
   end
end
%%
%%
function channel_directory(masterFolder, patientFiles, ElectrodeFolder, eventsFolder)
 for n = 1:length(patientFiles)
   y = patientFiles{n};
   for p=1:length(ElectrodeFolder)
     z = ElectrodeFolder{p};
     for m = 1:length(eventsFolder)
         a = eventsFolder{m};
         mkdir(fullfile(masterFolder, y, z, a));
     end
   end
 end
end
function M = getMaxima(EEGdata)
n = 0;
Fs = 512;
M = [];
for i = 1:length(EEGdata)
   events = EEGdata(i).events';
   t1 = 1;
   t2 = Fs*10;
   k=1;
 
   while t2 <= Fs*length(events)
       segment = events(t1:min(t2,length(events)));
       t1 = t1 + Fs*10;
       t2 = t2 + Fs*10;
       k = k + 1;
      
       if length(segment) > 8*Fs
           n = n + 1;
           [~,signalLength] = size(segment);
           fb = cwtfilterbank(SignalLength=signalLength,VoicesPerOctave=12);
           cfs = abs(fb.wt(segment));
           M{n} = max(cfs);
       else
       end
   end
end
end
%%
function threshold = removeOutliers(max, percentage)
   A = cell2mat(max);
   x = 100 - percentage;
   y0 = prctile(A,[0,x]);
   threshold = A(A<y0(2));
end
%%
% FUNCTIONS
function times(r1, s1, s2)
   reg0 = datetime(r1, 'InputFormat', 'HH.mm.ss');
   sz0 = datetime(s1, 'InputFormat', 'HH.mm.ss');
   sz1 = datetime(s2, 'InputFormat', 'HH.mm.ss');
   t_onset = seconds(time(between(reg0,sz0)));
   length = seconds(time(between(sz0,sz1)));
   t_end = length + t_onset;
   fprintf('Seizure Range: \t %g - %g seconds \n\nSeizure Length: \t %g seconds \n\n ', t_onset,t_end,length)
end
function bounds(length_pre_ictal, length_post_ictal, seizure_start, seizure_end)
   pre_ictal_start = seizure_start - length_pre_ictal;
   post_ictal_end = seizure_end + length_post_ictal;
   fprintf('Pre-ictal Start: \t %g seconds \n\n Post-ictal End: \t %g seconds \n\n ', pre_ictal_start,post_ictal_end)
end
% 5 groups of classification
function [inter0,pre,ictal,post, inter1] = get_Times(X, pre_ictal_start, ictal_start, ictal_end, post_ictal_end, fs)
   inter0 = X(1 : (pre_ictal_start-1)*fs);                 % (before seizure)
   pre = X(pre_ictal_start*fs : (ictal_start)*fs);         % pre-ictal
   ictal = X(ictal_start*fs+1 : ictal_end*fs);             % ictal
   post = X(ictal_end*fs+1 : post_ictal_end*fs);           % post-ictal
   inter1 = X(post_ictal_end*fs+1: length(X));             % (after seizure)
   % where X = dataset
end
% Obtaining electrode data from Timetable
function A = EEGsubset(timetable, label_array)
   for i = 1:length(label_array)
       A{i} = cell2mat([timetable.(label_array{i}); i + 1]);
   end
end
% Converting electrode data into structure w/ labels
function structure = subset2structure(subset, label_array)
   for i = 1:length(subset)
       structure(i).electrode_data = subset{i};
       structure(i).labels = label_array{i};
   end
end
% proper naming
function structure = subset2structure2(subset, label_array)
   for i = 1:length(subset)
       structure(i).events = subset{i};
       structure(i).labels = label_array{i};
   end
end
% Master structure for data manipulation where seizure events are indexed
% and labeled
function patient_data = genStructure(tt, electrode_array, pre_ictal_start, ictal_start, ictal_end, post_ictal_end, fs)
   t = EEGsubset(tt, electrode_array{1});
   temporal = subset2structure(t, electrode_array{1});
  
   f = EEGsubset(tt, electrode_array{2});
   frontal = subset2structure(f, electrode_array{2});
   c = EEGsubset(tt, electrode_array{3});
   central = subset2structure(c, electrode_array{3});
   p = EEGsubset(tt, electrode_array{4});
   parietal = subset2structure(p, electrode_array{4});
  
   o = EEGsubset(tt, electrode_array{5});
   occipital = subset2structure(o, electrode_array{5});
   patient_data = [temporal, frontal, central, parietal, occipital];
   for i = 1:length(patient_data)
       X = patient_data(i).electrode_data;
       [inter0, pre, ictal, post, inter1] = get_Times(X, pre_ictal_start, ictal_start, ictal_end, post_ictal_end, fs);
       A = {inter0, pre, ictal, post, inter1};
       event_labels = {'Inter_ictal0','Pre_ictal','Ictal','Post_ictal','Inter_Ictal1'};
       patient_data(i).electrode_data = subset2structure2(A, event_labels);
   end
end
% Converting electrode data into structure w/ labels
function structure = patient_structure(subset, label_array)
   for i = 1:length(subset)
       structure(i).patients = subset{i};
       structure(i).labels = label_array{i};
   end
end
% Converting electrode data into structure w/ labels
function structure = overallstructure(subset, label_array)
   for i = 1:length(subset)
       structure(i).files = subset{i};
       structure(i).labels = label_array{i};
   end
End
