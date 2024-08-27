net = trainedVGG;
events = {{'Inter_ictal0'},{'Pre_ictal'},{'Ictal'},{'Post_ictal'},{'Inter_ictal1'}};
root6 = 'C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Features\Sem2\CWT5';
root17 = 'C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Features\Sem2\CWT3';
root01 = 'C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Features\Sem2\CWT5';
files6 = {{'\PN06_1'}, {'\PN06_2'}, {'\PN06_3'}, {'\PN06_5'}};
files17 = {{'\PN17_1'}, {'\PN17_2'}};
files01 = {'\PN01_2'};
files12 = {{'\PN12_3'}, {'\PN17_4'}};
files13 = {{'\PN13_1'}, {'\PN13_2'}, {'\PN13_3'}};
files14 = {{'\PN14_1'}, {'\PN14_2'}, {'\PN14_4'}};
files09 = {{'\PN09_1'}, {'\PN09_2'}, {'\PN09_3'}};
files16 = {{'\PN16_1'}, {'\PN16_2'}};
files5 = {{'\PN05_2'}, {'\PN05_3'}, {'\PN05_4'}};
%%
events = {{'Inter_ictal0'},{'Pre_ictal'},{'Ictal'},{'Post_ictal'}};
data92 = getActivations(events,net,root01,files09{2}, 0.7);
%%
clc
root = root01;
files = files17{3};
threshold = 0.7;
labels = getFolders(strcat(root,char(files{1})));
YPredo = {};
scoreso = {};
signal = {};
for p = 1:3
   event = cell(events{p});
   for i = 1:length(labels)
       idxer = {strcat('\',labels{i})};
       fileLocations = getLocs(root, files, idxer, event);
       testImages = imageDatastore(fileLocations, ...
       "IncludeSubfolders",true, ...
       "LabelSource",'foldernames');
       ordered = natsort(testImages.Files);
       testImages.Files = ordered;
       [~, scoreso{i}] = classify(net, testImages);
   end
  
   ic = {};
   A = cell2mat(scoreso);
  
   for j = 1:29
      ic{j} = A(:,(2*j-1),:);
   end
   ictals = cell2mat(ic);
   ictals = gpuArray(ictals);
  
   flags = {};
  
   for q = 1:length(ictals)
       for b = 1:length(labels)
           if ictals(q,b) > 0.7
               flags{q,b} = 1;
           else
               flags{q,b} = 0;
           end
       end
   end
  
   signal173{p} = sum(cell2mat(flags),2);
end
%%
sz1 = 478;
sz2 = 886;
sz3 = 627;
pt64 = [signal64{1}; signal64{2}; signal64{3}];
figure;
plot(movmean(pt61,30))
%%
signal6 = {};
for i = 1:4
   signal6{i} = getActivations(events,net,root6,files6{i}, 0.8);
end
%%
net = trainedNet;
signal1 = getActivations(events,net,root01,files01, 0.8);
%%
r1 = '06.25.51'; % Registration Start Time
%skip Resistration End Time
s1 = '08.10.26'; % Seizure Start Time
s2 = '08.11.08'; % Seizure End Time
times2(r1, s1, s2, 8)
%%
a91 = [signal091{1}; signal091{2}];
figure;
plot(movmean(a91',30))
%%
Data09 = [signal091{1}, signal091{2}; signal092{1}, signal091{2}; signal093{1}, signal093{2}];
Data01 = [signal012{1}, signal012{2}];
Data14 = [signal142{1}, signal142{2}; signal144{1}, signal144{2}];
Data17 = [signal171{1}; signal171{2}; signal172{1}, signal172{2}];
Data06 = [signal6{1}, signal6{2};signal62{1}, signal62{2};signal63{1}, signal63{2};signal64{1}, signal64{2}];
%%
Data14 = [cell2mat(signal142'); cell2mat([signal144{1}; signal144{2}]')]
%%
figure;
plot([signal144{1}; signal144{2}])
%%
Data14 = [signal144{1}; signal144{2}]';
%% CREATING AND PLOTTING DISTRIBUTIONS
pt6 = [signal6{1,1};signal6{1,2};signal6{1,3};signal6{1,4}];
%%
flags = [flags1T+flags2T];
figure;
sgtitle('Two flagging regimes (PN09-2)',FontSize=16)
subplot(311)
plot(flags1T, LineWidth=4);
xline(712,'-r', 'Seizure Onset', LineWidth=3)
xline(712-180, '--k', '30 min before Seizure', LineWidth=3)
subplot(312)
plot(flags2T, LineWidth=4);
xline(712,'-r', 'Seizure Onset', LineWidth=3)
xline(712-180, '--k', '30 min before Seizure', LineWidth=3)
subplot(313)
plot(flags, LineWidth=4);
xline(712,'-r', 'Seizure Onset', LineWidth=3)
xline(712-180, '--k', '30 min before Seizure', LineWidth=3)
xlabel('Frames (10 sec)')
%%
A = [signal1{1}; signal1{2}];
B = movmean(A, 60);
figure;
plot(B)
%%
sigs2 = OverallMovemean(pt6, 60);
A1 = get_Times(sigs2{1}, 378, 516, 558, 622, 682);
A2 = get_Times(sigs2{2}, 706, 844, 886, 955, 1015);
A3 = get_Times(sigs2{3}, 447, 585, 627, 669, 729);
A4 = get_Times(sigs2{4}, 298, 436, 478, 522, 582);
signal6events = [A1;A2;A3;A4];
[II0, Pre1, Pre2, Seizure, Post, II1] = obtainEvents(signal6events);
pd_II0 = fitdist(II0,'Normal');
pd_Pre1 = fitdist(Pre1,'Normal');
pd_Pre2 = fitdist(Pre2,'Normal');
pd_SZ = fitdist(Seizure,'Normal');
pd_Po = fitdist(Post,'Normal');
pd_II1 = fitdist(II1,'Normal');
x_values = 0:.01:29;
   pdf_II0 = pdf(pd_II0, x_values);
   pdf_Pre1 = pdf(pd_Pre1, x_values);
   pdf_Pre2 = pdf(pd_Pre2, x_values);
   pdf_SZ = pdf(pd_SZ, x_values);
   pdf_Po = pdf(pd_Po, x_values);
   pdf_II1 = pdf(pd_II1, x_values);
  
 
figure;
subplot(3,1,1)
plot(x_values, pdf_II0, 'black', "LineWidth",3)
hold on
plot(x_values, pdf_Pre1, 'yellow', "LineWidth",3)
hold on
plot(x_values, pdf_Pre2, 'blue', "LineWidth",3)
hold on
plot(x_values, pdf_SZ ,'red', "LineWidth",3)
hold off
legend('Interictal (30 min away from Seizure)', "Pre-Ictal (30 min before Seizure)", "10 min before Seizure","Seizure", 'FontSize', 14);
ylabel("Probability");
title('PDFs of Seizure Events (Patients 06 + 17)');
subplot(3,1,2)
histfit(II0, 20)
hold on
histfit(Pre1, 20)
hold on
histfit(Pre2, 20)
hold on
histfit(Seizure, 20)
hold off
subplot(3,1,3)
histfit(II0, 100, 'kernel')
hold on
histfit(Pre1, 100, 'kernel')
hold on
histfit(Pre2, 100, 'kernel')
hold on
histfit(Seizure, 100, 'kernel')
xlabel('Flagged Electrodes');
hold off
%%
figure;
Y = fft(M);
Fs = 1;
L = length(M);
plot(Fs/L*(-L/2:L/2-1),abs(fftshift(Y)),"LineWidth",3)
title("fft Spectrum in the Positive and Negative Frequencies")
xlabel("f (Hz)")
ylabel("|fft(X)|")
%% PLOTTING LENGTH OF SEIZURES ----NEW NET
sigs2 = OverallMovemean(pt6, 30);
M = [sigs2{1}, sigs2{2}, sigs2{3},sigs2{4}];
t = 1:length(M);
figure;
plot(t,M)
ylim([0 15])
yline(4.32)
yline(6.75)
yline(8.31)
yline(10.6)
xline(558, LineWidth=2)
xline(622, LineWidth=2)
xline(length(sigs2{1})+886, LineWidth=2)
xline(length(sigs2{1})+995, LineWidth=2)
xline(length([sigs2{1},sigs2{2}])+628, LineWidth=2)
xline(length([sigs2{1},sigs2{2}])+670, LineWidth=2)
A = length(M) - length(sigs2{4});
xline(A+478, LineWidth=2)
xline(A+522, LineWidth=2)
hold on
plot(M,'LineWidth',2)
yregion(0,4.32,"FaceColor","#0072BD");
yregion(4.32,6.75,"FaceColor","#EDB120");
yregion(6.75,8.31,"FaceColor","#D95319");
yregion(8.31,10.6,"FaceColor",'r');
yregion(10.6,29,"FaceColor","#A2142F");
xlabel('time')
ylabel('Flagged Electrodes')
title('Patient 6 Seizures')
hold off
%% PLOTTING ONE SEIZURE
M = sigs2{2};
t = 1:length(M);
figure;
yline(4.32)
yline(6.75)
yline(8.31)
yline(10.6)
xline(886, LineWidth=2)
xline(995, LineWidth=2)
hold on
plot(t,M,'black','LineWidth',2)
yregion(0,4.32,"FaceColor","#0072BD");
yregion(4.32,6.75,"FaceColor","#EDB120");
yregion(6.75,8.31,"FaceColor","#D95319");
yregion(8.31,10.6,"FaceColor",'r');
yregion(10.6,29,"FaceColor","#A2142F");
xlabel('time')
ylabel('Flagged Electrodes')
title('Patient 06-2 Seizure')
%% OBTAINING DATA SET FOR REGRESSOR
PN061 = [signal6{1}{1};signal6{1}{2}];
PN062 = [signal6{2}{1};signal6{2}{2}];
PN063 = [signal6{3}{1};signal6{3}{2}];
PN065 = [signal6{4}{1};signal6{4}{2}];
Data1 = {PN061;PN062;PN063;PN065};
Data1{1} = paddata(flip(Data1{1}),886);
Data1{3} = paddata(flip(Data1{3}),886);
Data1{4} = paddata(flip(Data1{4}),886);
Data2 = {};
for i = 1:4
   Data2{i} = movmean(Data1{i},60);
end
%% PLOTTING THE EVENTS LEADING TO SEIZURE
figure;
t = length(Data2{1}):-1:1;
plot(t,Data2{4})
hold on
plot(t,Data2{3})
hold on
plot(t,Data2{2})
hold on
plot(t,Data2{1})
%% OBTAINING LIKELIHOOD DATA
clc
range = length(Data2{1});
SZVsPre1T = zeros(4,range);
pre2Vspre1T = zeros(4,range);
SZVsIIT = zeros(4,range);
for i = 1:4
   X = Data2{i};
   for j = 1:length(X)
       %SZVsPre1T(i,j) = log(pdf(pd_SZ,X(j))./pdf(pd_Pre1, X(j)));
       %pre2Vspre1T(i,j) = log(pdf(pd_Pre2, X(j))./pdf(pd_Pre1,X(j)));
      
       SZVsIIT(i,j) = log(pdf(pd_SZ,X(j))./pdf(pd_II0, X(j)));
   end
end
%% PLOTTING AND FITTING LINEAR MODEL
len = 60;
t1 = 1:61;
Mean = mean(SZVsIIT,1);
data1= Mean(1:61);
figure;
scatter(data1,log(t1))
%[p, gof] = fitlm(Mean', log(t)', 'poly3','Normalize','on','Robust','LAR');
mdl1 = fitlm(data1', log(t1)', 'RobustOpts','on');
hold on
plot(mdl1)
hold on
%%
figure;
t2 = 60:180;
data2= Mean(60:180);
scatter(data2,t2)
%[p, gof] = fitlm(Mean', log(t)', 'poly3','Normalize','on','Robust','LAR');
mdl2 = fitlm(data2', t2', 'RobustOpts','on');
hold on
plot(mdl2)
%% DOUBLE Y AXIS PLOT OF LIKELIHOODS AND ELECTRODES BASED ON TIME TO ONSET
figure;
for i = 1:4
   x = Data2{i};
   t = 1:length(x);
   yyaxis left
   SZVsPre1 = pdf(pd_SZ,x)./pdf(pd_Pre1, x);
   pre2Vspre1 = pdf(pd_Pre2, x)./pdf(pd_Pre1,x);
   SZVsII = pdf(pd_SZ,x)./pdf(pd_II0, x);
   scatter(x,t)
   title('30 minutes To Seizure')
   ylabel('Time to Onset')
   xlabel('# of Flagged Electrodes')
   hold on
  
   hold on
   yyaxis right
  
   scatter(x, SZVsPre1, 'r')
   hold on
   yline(0.9)
   scatter(x, pre2Vspre1,'black')
   hold on
   scatter(x, SZVsII, 'b')
   legend('Seizure vs. Pre-Ictal', "Seizure vs. Interictal",'Location','northwest');
   hold on
   ylabel('Ratio of Likelihood')
   yscale log
  
end
hold off
%%
figure;
for i = 1:4
   x = Data2{i};
   t = 1:length(x);
   SZVsII = log(pdf(pd_SZ,x)./pdf(pd_II0, x));
 
   scatter(SZVsII, log(t))
   hold on
   xlabel('Ratio of Likelihoods')
   ylabel('Time from Seizure Onset (10sec chunks)')
   %yscale log
   title("Basis of Regressor")
end
%% PLOTTING MODEL BACK ONTO SEIZURE FILES
sigs3 = OverallMovemean(pt6, 30);
%sigs2 = OverallMovemean(pt6, 90);
M = sigs3{1};
t = 1:length(M);
figure;
subplot(2,1,1)
plot(t,M)
%xline(length(sigs2{1})+886)
%xline(length(sigs2{1})+995)
%xline(length([sigs2{1},sigs2{2}])+628)
%xline(length([sigs2{1},sigs2{2}])+670)
A = length(M) - length(sigs2{4});
%xline(A+478)
%xline(A+522)
yline(4.32)
yline(6.75)
yline(8.31)
yline(10.6)
xline(558, LineWidth=2)
xline(622, LineWidth=2)
ylim([0 5])
hold on
plot(t,M,'black','LineWidth',2)
yregion(0,4.32,"FaceColor","#0072BD");
yregion(4.32,6.75,"FaceColor","#EDB120");
yregion(6.75,8.31,"FaceColor","#D95319");
yregion(8.31,10.6,"FaceColor",'r');
yregion(10.6,29,"FaceColor","#A2142F");
subplot(2,1,2)
X = M;
R3= log(pdf(pd_SZ,X)./pdf(pd_II0, X));
ypred3 = predict(mdl1, R3');
hold on
plot(ypred3)
xline(558, LineWidth=2)
ylim([-50 50])
yline(-5)
yline(200)
yline(0)
ylabel('Time To Onset')
xlabel('log(Ratio of Likelihoods)')
%%
figure;
plot(558-ypred1,R1)
%%
ypred2 = predict(model2, R2');
hold on
plot(t+50,ypred2)
ypred3 = predict(model3, R3');
hold on
plot(t+50,ypred3)
%plot(poly2, t, R2, 'b')
%yscale log
%xlim([0 200])
%%
%%
X = sigs3{1}(500);
R1 = log(pdf(pd_SZ,X)./pdf(pd_Pre1, X));
predict(model1, R1')
%%
Xx = signals06_3{1};
R1 = log(pdf(pd_SZ,Xx)./pdf(pd_Pre1, Xx));
yf = predict(model1, R1', 50);
figure;
plot(R1, yf)
%%
p = 3;
PriorMdl = bayeslm(p,'ModelType','semiconjugate','VarNames',["R1" "R2" "R3"]);
fhs  = 10;
X = [data1;data2;data3];
x = X(:,1:(end-fhs))';
xf = X(:,(end - fhs + 1):end)';
y = 1:90-fhs;
yft = 50:90;
PosteriorMdl = estimate(PriorMdl,x,y,'Display',false);
%%
figure;
t = 90:-1:1;
plot(X,t)
hold on
plot(xf,yF)
%%
tt = 1:10;
[yF,YFCov] = forecast(PosteriorMdl,xf);
cil = yF - norminv(0.975)*sqrt(diag(YFCov));
ciu = yF + norminv(0.975)*sqrt(diag(YFCov));
figure;
hold on
h=gca;
plot(xf,yF)
plot(tt,[cil ciu],'k--')
hp = patch([X(end - fhs + 1) X(end) X(end) X(end - fhs + 1)],...
   h.YLim([1,1,2,2]),[0.8 0.8 0.8]);
uistack(hp,'bottom');
legend('Forecast horizon','True GNPR','Forecasted GNPR',...
   'Credible interval','Location','NW')
title('Real Gross National Product: 1909 - 1970');
ylabel('rGNP');
xlabel('Year');
hold off
%%
predict(exp1,1)
%%
f1 = fitlm(t',data1');
f2 = fitlm(t',data2');
%%
X = zeros(1,90);
X = signals06{1};
%%
clc
figure;
for i = 1:4
   x = signals06_1{i};
   preVsSZ = log(pdf(pd_Pre, x)./pdf(pd_SZ,x));
   preVsII = log(pdf(pd_II0, x)./pdf(pd_Pre,x));
   SZVsII = log(pdf(pd_II0, x)./pdf(pd_SZ,x));
  
       plot(x, preVsII, 'black')
       hold on
       plot(x, preVsSZ, 'blue')
       hold on
       plot(x, SZVsII,'red')
       hold on
       ylabel("Ratio of Likelihood")
       xlabel("# of Flagging Electrodes")
       hold on
end
hold off
%%
figure;
plot(signals06)
%%
figure;
plot(signal11);
hold on
plot(signal21)
hold on
plot(signal31)
hold on
plot(signal41)
hold off
%%
clc
sigs2 = OverallMovemean(pt6, 60);
%%
cell2mat(sigs2{1}')
%%
ind = 1:length()
t1 = find(pdf(pd_Pre,x)==pdf(pd_SZ,x));
disp(find(preVsSZ==1))
disp(find(SZVsII==1))
%%
figure;
subplot(3,1,1)
plot(x_values, pdf_II0, 'black', "LineWidth",3)
hold on
plot(x_values, pdf_Pre, 'blue', "LineWidth",3)
hold on
plot(x_values, pdf_SZ ,'red', "LineWidth",3)
hold off
legend('Interictal (30 min away from Seizure)', "Pre-Ictal (30 min before Seizure)", "Seizure", 'FontSize', 14);
ylabel("Probability");
title('PDFs of Seizure Events (Patients 06 + 17)');
subplot(3,1,2)
histfit(II0)
hold on
histfit(Pre)
hold on
histfit(Seizure)
hold off
subplot(3,1,3)
histfit(II0, 100, 'kernel')
hold on
histfit(Pre, 100, 'kernel')
hold on
histfit(Seizure, 100, 'kernel')
xlabel('Flagged Electrodes');
hold off
%% NEW DIST
%%
plot(x_values, pdf_Po, 'yellow')
hold on
plot(x_values, pdf_II1, 'black')
hold off
%%
%% CALCULATING MOVMEAN FEATURES FOR CNN ACTIVATIONS   / LSTMS
clc
data0 = {PN06_1'; PN06_2'; PN06_3'; PN06_5'};
data = {};
for i = 1:4
   data{i} = movmean(data0{i},120);
end
movmean_data = data';
%% Viewing individual activations
JJ = cell2mat(OverallMovemean(signal172, 1));
M = cell2mat(OverallMovemean(signal172, 60));
t = 1:numel(M);
figure;
plot(t,JJ)
plot(t,M,'LineWidth',2)
hold on
xlabel("Time (10 sec)")
ylabel("# of Flagging Electrodes")
title("PN06-4")
%%
figure;
tiledlayout(2,2)
for i = 1:3
   nexttile
   stackedplot(data{i}')
   xlabel("Time Step")
end
%%
function folders = getFolders(root)
   s=dir(root);
   idx=~startsWith({s.name},'.') & [s.isdir];
   folders={s(idx).name};
end
function signal = getActivations(events, net, root, files, threshold)
labels = getFolders(strcat(root,char(files{1})));
YPredo = {};
scoreso = {};
signal = {};
for p = 1:4
   event = cell(events{p});
   for i = 1:length(labels)
       idxer = {strcat('\',labels{i})};
       fileLocations = getLocs(root, files, idxer, event);
       testImages = imageDatastore(fileLocations, ...
       "IncludeSubfolders",true, ...
       "LabelSource",'foldernames');
       %ordered = natsort(testImages.Files);
       %testImages.Files = ordered;
       [~, scoreso{i}] = classify(net, testImages);
   end
  
   ic = {};
   A = cell2mat(scoreso);
  
   for j = 1:29
      ic{j} = A(:,(2*j-1),:);
   end
   ictals = cell2mat(ic);
   ictals = gpuArray(ictals);
  
   flags = {};
  
   for q = 1:length(ictals)
       for b = 1:length(labels)
           if ictals(q,b) > threshold
               flags{q,b} = 1;
           else
               flags{q,b} = 0;
           end
       end
   end
  
   signal{p} = sum(cell2mat(flags),2);
end
end
function fileLocations = getLocs(root, files, electrodes, events)
place = 1;
for n1 = 1:length(files)
   file{n1} = strcat(root, files{n1});
   for i1 = 1:length(electrodes)
       eFile{i1} = strcat(file{n1}, electrodes{i1});
       for j1 = 1:length(events)
           fileLocations{place} = fullfile(eFile{i1}, events{j1});
           place = place+1;
       end
   end
end
end
function sig2 = OverallMovemean(signal, k)
sig = {};
sig2 = {};
   for i = 1:size(signal,1)
      sig{i} = {signal{i,1}'; signal{i,2}'; signal{i,3}'; signal{i,4}'; signal{i,5}'};
      A = cell2mat(sig{i}');
      sig2{i} = movmean(A,k);
   end
end
function  A = get_Times(X, pre1_start, pre2_start, ictal_start, ictal_end, post_ictal_end)
   inter0 = X(1 : (pre1_start-1));                 % (before seizure)
   pre1 = X(pre1_start +1: (pre2_start));                 % pre-ictal
   pre2 = X(pre2_start +1: (ictal_start));
   ictal = X(ictal_start+1 : ictal_end);             % ictal
   post = X(ictal_end+1 : post_ictal_end);           % post-ictal
   inter1 = X(post_ictal_end+1: length(X));             % (after seizure)
   % where X = dataset
   A = {inter0,pre1,pre2, ictal,post, inter1};
end
function [II0, Pre1, Pre2,Seizure, Post, II1] = obtainEvents(signal)
BS = {};
Pre1 = {};
Pre2 = {};
SZ = {};
Po = {};
AS = {};
   for i = 1:size(signal,1)
       for j = 1:6
           if j == 1
               BS{i} = signal{i, j};
           elseif j == 2
               Pre1{i} = signal{i, j};
           elseif j==3
               Pre2{i} = signal{i, j};
           elseif j == 4
               SZ{i} = signal{i, j};
           elseif j == 5
               Po{i} = signal{i, j};
           elseif j == 6
               AS{i} = signal{i, j};
           end
       end
   end
II0 = cell2mat(BS)';
Pre1 = cell2mat(Pre1)';
Pre2 = cell2mat(Pre2)';
Seizure = cell2mat(SZ)';
Post = cell2mat(Po)';
II1 = cell2mat(AS)';
end
function [t_onset, length] = times(r1, s1, s2)
   reg0 = datetime(r1, 'InputFormat', 'HH.mm.ss');
   sz0 = datetime(s1, 'InputFormat', 'HH.mm.ss');
   sz1 = datetime(s2, 'InputFormat', 'HH.mm.ss');
   t_onset = floor(seconds(time(between(reg0,sz0))));
   length = seconds(time(between(sz0,sz1)));
   t_end = length + t_onset;
   fprintf('Seizure Range: \t %g - %g seconds \n\nSeizure Length: \t %g seconds \n\n ', t_onset,t_end,length)
end
function [t_onset, length] = times2(r1, s1, s2, min)
   reg0 = datetime(r1, 'InputFormat', 'HH.mm.ss');
   sz0 = datetime(s1, 'InputFormat', 'HH.mm.ss');
   sz1 = datetime(s2, 'InputFormat', 'HH.mm.ss');
   t_onset = floor(seconds(time(between(reg0,sz0)))/10);
   length = seconds(time(between(sz0,sz1)));
   t_end = length + t_onset;
   fprintf('Seizure Range: \t %g - %g seconds \n\nSeizure Length: \t %g seconds \n\n ', t_onset,t_end,length)
   pre1_t = t_onset - 180;
   pre2_t = t_onset - min*6;
   fprintf('Pre ranges: \t %g - %g seconds ', pre1_t,pre2_t)
   post = t_end + 60;
   fprintf("Post: %g",post)
end
function signal = scrapeoutActivations(sig, time, r1, s1, s2)
   [t_onset, length] = times(r1, s1, s2);
   t_onset = round(t_onset/10);
   time_cutoff = t_onset - time;
   signal = sig(time_cutoff:t_onset-1);
end
function bounds(length_pre_ictal, length_post_ictal, seizure_start, seizure_end)
   pre_ictal_start = seizure_start - length_pre_ictal;
   post_ictal_end = seizure_end + length_post_ictal;
   fprintf('Pre-ictal Start: \t %g seconds \n\n Post-ictal End: \t %g seconds \n\n ', pre_ictal_start,post_ictal_end)
end
function [B,ndx,dbg] = natsort(A,rgx,varargin)
% Natural-order / alphanumeric sort the elements of a text array.
%
% (c) 2012-2023 Stephen Cobeldick
%
% Sorts text by character code and by number value. By default matches
% integer substrings and performs a case-insensitive ascending sort.
% Options to select the number format, sort order, case sensitivity, etc.

fnh = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;
%
if iscell(A)
	assert(all(fnh(A(:))),...
		'SC:natsort:A:CellInvalidContent',...
		'First input <A> cell array must contain only character row vectors.')
	C = A(:);
elseif ischar(A) % Convert char matrix:
	assert(ndims(A)<3,...
		'SC:natsort:A:CharNotMatrix',...
		'First input <A> if character class must be a matrix.') %#ok<ISMAT>
	C = num2cell(A,2);
else % Convert string, categorical, datetime, enumeration, etc.:
	C = cellstr(A(:));
end
%
chk = '(match|ignore)(case|dia)|(de|a)scend(ing)?|(char|nan|num)[<>](char|nan|num)|%[a-z]+';
%
if nargin<2 || isnumeric(rgx)&&isequal(rgx,[])
	rgx = '\d+';
elseif ischar(rgx)
	assert(ndims(rgx)<3 && size(rgx,1)==1,...
		'SC:natsort:rgx:NotCharVector',...
		'Second input <rgx> character row vector must have size 1xN.') %#ok<ISMAT>
	nsChkRgx(rgx,chk)
else
	rgx = ns1s2c(rgx);
	assert(ischar(rgx),...
		'SC:natsort:rgx:InvalidType',...
		'Second input <rgx> must be a character row vector or a string scalar.')
	nsChkRgx(rgx,chk)
end
%
varargin = cellfun(@ns1s2c, varargin, 'UniformOutput',false);
ixv = fnh(varargin); % char
txt = varargin(ixv); % char
xtx = varargin(~ixv); % not
%
% Sort direction:
tdd = strcmpi(txt,'descend');
tdx = strcmpi(txt,'ascend')|tdd;
% Character case:
tcm = strcmpi(txt,'matchcase');
tcx = strcmpi(txt,'ignorecase')|tcm;
% Char/num order:
ttn = strcmpi(txt,'num>char')|strcmpi(txt,'char<num');
ttx = strcmpi(txt,'num<char')|strcmpi(txt,'char>num')|ttn;
% NaN/num order:
ton = strcmpi(txt,'num>NaN')|strcmpi(txt,'NaN<num');
tox = strcmpi(txt,'num<NaN')|strcmpi(txt,'NaN>num')|ton;
% SSCANF format:
tsf = ~cellfun('isempty',regexp(txt,'^%([bdiuoxfeg]|l[diuox])$'));
%
nsAssert(txt, tdx, 'SortDirection', 'sort direction')
nsAssert(txt, tcx,  'CaseMatching', 'case sensitivity')
nsAssert(txt, ttx,  'CharNumOrder', 'number-character order')
nsAssert(txt, tox,   'NanNumOrder', 'number-NaN order')
nsAssert(txt, tsf,  'sscanfFormat', 'SSCANF format')
%
ixx = tdx|tcx|ttx|tox|tsf;
if ~all(ixx)
	error('SC:natsort:InvalidOptions',...
		['Invalid options provided. Check the help and option spelling!',...
		'\nThe provided options:%s'],sprintf(' "%s"',txt{~ixx}))
end
%
% SSCANF format:
if any(tsf)
	fmt = txt{tsf};
else
	fmt = '%f';
end
%
xfh = cellfun('isclass',xtx,'function_handle');
assert(nnz(xfh)<2,...
	'SC:natsort:FunctionHandle:Overspecified',...
	'The function handle option may only be specified once.')
assert(all(xfh),...
	'SC:natsort:InvalidOptions',...
	'Optional arguments must be character row vectors, string scalars, or function handles.')
if any(xfh)
	txfh = xtx{xfh};
end
%
%% Identify and Convert Numbers %%
%
[nbr,spl] = regexpi(C(:), rgx, 'match','split', txt{tcx});
%
if numel(nbr)
	V = [nbr{:}];
	if strcmp(fmt,'%b')
		V = regexprep(V,'^0[Bb]','');
		vec = cellfun(@(s)pow2(numel(s)-1:-1:0)*sscanf(s,'%1d'),V);
	else
		vec = sscanf(strrep(sprintf(' %s','0',V{:}),',','.'),fmt);
		vec = vec(2:end); % SSCANF wrong data class bug (R2009b and R2010b)
	end
	assert(numel(vec)==numel(V),...
		'SC:natsort:sscanf:TooManyValues',...
		'The "%s" format must return one value for each input number.',fmt)
else
	vec = [];
end
%
%% Allocate Data %%
%
% Determine lengths:
nmx = numel(C);
lnn = cellfun('length',nbr);
lns = cellfun('length',spl);
mxs = max(lns);
%
% Allocate data:
idn = permute(bsxfun(@le,1:mxs,lnn),[2,1]); % TRANSPOSE lost class bug (R2013b)
ids = permute(bsxfun(@le,1:mxs,lns),[2,1]); % TRANSPOSE lost class bug (R2013b)
arn = zeros(mxs,nmx,class(vec));
ars =  cell(mxs,nmx);
ars(:) = {''};
ars(ids) = [spl{:}];
arn(idn) = vec;
%
%% Debugging Array %%
%
if nargout>2
	dbg = cell(nmx,0);
	for k = 1:nmx
		V = spl{k};
		V(2,:) = [num2cell(arn(idn(:,k),k));{[]}];
		V(cellfun('isempty',V)) = [];
		dbg(k,1:numel(V)) = V;
	end
end
%
%% Sort Matrices %%
%
if ~any(tcm) % ignorecase
	ars = lower(ars);
end
%
if any(ttn) % char<num
	% Determine max character code:
	mxc = 'X';
	tmp = warning('off','all');
	mxc(1) = Inf;
	warning(tmp)
	mxc(mxc==0) = 255; % Octave
	% Append max character code to the split text:
	%ars(idn) = strcat(ars(idn),mxc); % slower than loop
	for ii = reshape(find(idn),1,[])
		ars{ii}(1,end+1) = mxc;
	end
end
%
idn(isnan(arn)) = ~any(ton); % NaN<num
%
if any(xfh) % external text-sorting function
	[~,ndx] = txfh(ars(mxs,:));
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),txt{tdx});
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),txt{tdx});
		ndx = ndx(idx);
		[~,idx] = txfh(ars(ii,ndx));
		ndx = ndx(idx);
	end
elseif any(tdd)
	[~,ndx] = sort(nsGroups(ars(mxs,:)),'descend');
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),'descend');
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),'descend');
		ndx = ndx(idx);
		[~,idx] = sort(nsGroups(ars(ii,ndx)),'descend');
		ndx = ndx(idx);
	end
else
	[~,ndx] = sort(ars(mxs,:)); % ascend
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),'ascend');
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),'ascend');
		ndx = ndx(idx);
		[~,idx] = sort(ars(ii,ndx)); % ascend
		ndx = ndx(idx);
	end
end
%
%% Outputs %%
%
if ischar(A)
	ndx = ndx(:);
	B = A(ndx,:);
else
	ndx = reshape(ndx,size(A));
	B = A(ndx);
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsort
function grp = nsGroups(vec)
% Groups in a cell array of char vectors, equivalent to [~,~,grp]=unique(vec);
[vec,idx] = sort(vec);
grp = cumsum([true(1,numel(vec)>0),~strcmp(vec(1:end-1),vec(2:end))]);
grp(idx) = grp;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsGroups
function nsChkRgx(rgx,chk)
% Perform some basic sanity-checks on the supplied regular expression.
chk = sprintf('^(%s)$',chk);
assert(isempty(regexpi(rgx,chk,'once')),...
	'SC:natsort:rgx:OptionMixUp',...
	['Second input <rgx> must be a regular expression that matches numbers.',...
	'\nThe provided input "%s" looks like an optional argument (inputs 3+).'],rgx)
if isempty(regexpi('0',rgx,'once'))
	warning('SC:natsort:rgx:SanityCheck',...
		['Second input <rgx> must be a regular expression that matches numbers.',...
		'\nThe provided regular expression does not match the digit "0", which\n',...
		'may be acceptable (e.g. if literals, quantifiers, or lookarounds are used).'...
		'\nThe provided regular expression: "%s"'],rgx)
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsChkRgx
function nsAssert(txt,idx,eid,opt)
% Throw an error if an option is overspecified.
if nnz(idx)>1
	error(sprintf('SC:natsort:%s:Overspecified',eid),...
		['The %s option may only be specified once.',...
		'\nThe provided options:%s'],opt,sprintf(' "%s"',txt{idx}));
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsAssert
function arr = ns1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
