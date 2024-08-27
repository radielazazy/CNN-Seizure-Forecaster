net = trainedVGG;
events = {{'Inter_ictal0'},{'Pre_ictal'},{'Ictal'},{'Post_ictal'},{'Inter_ictal1'}};
[B,ndx,dbg] = natsort(A,rgx,varargin);
%%
A = [signal142{1}; signal142{2}]';
B = [signal144{1}; signal144{2}]';
%%
Data092 = cell2mat(data92');
pi = [data92{1}; data92{2}]';
%%
% CHANGING PARAMETERS SO THAT THERE ARE NO FALSE POSITIVES
% AMOUNT OF FRAMES REQUIRED TO WARRANT A FLAG
% These seem ideal for PT6
J1 = 93;
J2 = 2;
t1 = 3;
t2 = 3;
G_t1 = 50;
G_t2 = 74;
w1 = 23;
w2 = 120;
tic
amt1 = 100;
amt2 = 100;
flag_no = 1;
A =cell(amt1,amt2);
B =cell(amt1,amt2);
%C =cell(amt1,amt2);
for k = 1:amt1
   for l = 1:amt2
       J1 = k;
       w1 = l;
       [~, ~, beyond30, in30,~] = Semaphores({pi}, J1, J2, w1, w2, t1, t2, G_t1, G_t2);
  
       A{k,l} = beyond30(:,flag_no);
       B{k,l} = in30(:,flag_no);
       %C{k,l} = in10(:,flag_no);
   end  
end
Sdiff1 = zeros(amt1, amt2);
Sdiff2 = zeros(amt1, amt2);
Sdiff3 = zeros(amt1, amt2);
clc
for i = 1:length(A)
   for j = 1:size(A,1)
       Sdiff1(i,j) = sum(A{i,j} - B{i,j});
       %Sdiff2(i,j) = sum(B{i,j} - C{i,j});
       %Sdiff3(i,j) = sum(A{i,j} - C{i,j});
   end
end
%%
figure;
title('Grid Search of Kurtosis Parameters')
surface(Sdiff1)
xlabel('Smoothing Window (movmean)')
ylabel('Kurtosis Window')
toc
%%
[R,C] = find(Sdiff1==min(Sdiff1(:)))
val = Sdiff1(R,C)
%%
sort(Sdiff1)
%%
max(R) * .1
min(C)*.2
[7,2];
%%
D = 1;
test = Data1{D};
w2 = 120;
M2w = 2;
M2 = movmean(test,M2w);
P2 = zeros(length(test),1);
for i=1:length(test)
   P2(i) = kurtosis(test(max(0,i-w2)+1:i));
end
w1 = 30;
M1w = 13;
M1 = movmean(test, M1w);
P1 = zeros(length(test),1);
for i=1:length(test)
   P1(i) = kurtosis(test(max(0,i-w1)+1:i));
end
figure;
plot(P2,LineWidth=2)
hold on
plot(P1,LineWidth=2)
xline(length(test),'-r', 'Seizure Onset', LineWidth=3)
xline(length(test)-180, '--k', '30 min before Seizure', LineWidth=3)
title('Kurtosis of Different Window Sizes (PN06)')
xlabel('time (10 sec)')
ylabel('Kurtosis')
legend('Large Window', 'Small Window', 'Location','northwest','FontSize', 16)
%%
t1 = 3;
t2 = 3;
J1 = 78;
J2 = 2;
w1 = 15;
w2 = 65;
G_t1 = 30;
G_t2 = 102;
[flags1T, flags2T, beyond30, in30, in10] = Semaphores({Data092}, J1, J2, w1, w2, t1, t2, G_t1, G_t2);
flagsT ={};
for D = 1:1
   flagsT{D} = flags1T{D} +flags2T{D};
end
%%
figure;
plot(flagsT{1})
%%
Flags = {flagsT{1}, flagsT{2}};
M = 1*movmean(cell2mat(Flags),180);
Mark = zeros(length(M),1);
for i = 1:length(M)
   if M(i)>4.3
       Mark(i) = 1;
   else
       Mark(i) = 0;
   end
end
SOZ_marks = zeros(size(Flags));
min30 = zeros(size(Flags));
for i=1:length(Flags)
   x = 0; s = length(Flags{i});
   if (i==1)
       SOZ_marks(i) = s+1;
       min30(i) = SOZ_marks(i)-180;
   else
       SOZ_marks(i) = SOZ_marks(i-1)+s+1;
       min30(i) = SOZ_marks(i)-180;
   end
end
flags1 = cell2mat(flags1T);
flags2 = cell2mat(flags2T);
%%
figure;
plot(flags1)
hold on
plot()
%%
fp = 1;
tp = 1;
data = Data9;
time = zeros(3, length(data{2}));
for i = 1:3
   for j = 1:length(data{i})
       if flags2T{i}(j) ==1 && j < (length(data{i}) - 180)
           fp = fp + 1;
       elseif flags2T{i}(j) ==1 && j >= (length(data{i}) - 180)
           tp = tp +1;
           time(i,j) = length(data{i})-j;
       end
   end
end
timeV = mean(nonzeros(time))
tp
fp
%%
figure;
plot(flags1, LineWidth=3)
hold on
xline(726)
xline(747+726)
xline(546+747+726)
line([t(SOZ_marks); t(SOZ_marks)]./10,repmat([0; 20],1,length(SOZ_marks)),'LineWidth',2,'Color','r','LineStyle','--','Marker','none');
line([t(min30); t(min30)]./10,repmat([0; 20],1,length(min30)),'LineWidth',2,'Color','k','LineStyle',':','Marker','none');
yline(4,LineWidth=2)
%%
clc
figure;
t1 = 1:length(Data1{4});
Marks = Mark(end-length(Data1{4})+1:end);
for i = 1:300
   plot(t1(i), MM1(i))
   if Mark(i) == 1
       area(MM1(i-1:i), t1(i-1:i))
   end
   hold on
  
end
%%
%%
Test = [signal64{1};signal64{2}; signal64{3}; signal64{4}];
SOZ = length([signal64{1}; signal64{2}]);
%%
i = 500;
t1 = 1:length(Test);
F = cell2mat(flags2T);
figure;
plot(t1(1:i), MM2(1:i))
hold on
Ls = length(nonzeros(F(1:i)));
funct = MM2;
plotFlags(Ls, i, F, funct)
plotLines(SOZ,i)
%%
xline(length(Data1{4})-180,'LineWidth',2,'Color','k','LineStyle',':','Marker','none');
%%
%%
figure;
plot(Data1{1})
%%
xline(length(Data2{D})-180, LineWidth=2)
xline(length(Data2{D})-60, LineWidth=2)
hold on
plot(Data2{D})
%fprintf("Threshold 1: %d \n\nThreshold 2: %d\n\nThreshold 3: %d\n\n", floor(mean(A)), floor(mean(B)), floor(mean(C)))
function [flags1T, flags2T, beyond30, in30, in10] = Semaphores(Data1, J1, J2, w1, w2, t1, t2, G_t1, G_t2)
  
   for i = 1:1
       Z1{i} = movmean(Data1{i},J1);
       Z2{i} = movmean(Data1{i},J2);
   end
C_count1 = 0;
C_count2 = 0;
flags1T = {};
flags2T = {};
in30 = zeros(4, 2);
in10 = zeros(4, 2);
beyond30 = zeros(4, 2);
for q = 1:length(Z1)
   flags1 = zeros(1, length(Z1{q}));
   flags2 = zeros(1, length(Z1{q}));
   P1 = zeros(length(Z1{q}),1);
   for i=1:length(Z1{q})
       P1(i) = kurtosis(Z1{q}(max(0,i-w1)+1:i));
   end
  
   for i = 2:length(Z1{q})
  
       if P1(i-1) < t1 && P1(i) < t1
           C_count1 = C_count1 + 1;
           if C_count1 >= G_t1
               flags1(i) = 1;
           end
       else
           C_count1 = 0;
       end
   end
   P2 = zeros(length(Z2{q}),1);
   for i=1:length(Z2{q})
       P2(i) = kurtosis(Z2{q}(max(0,i-w2)+1:i));
   end
  
   for i = 2:length(Z2{q})
  
       if P2(i-1) < t2 && P2(i) < t2
           C_count2 = C_count2 + 1;
           if C_count2 >= G_t2
               flags2(i) = 1;
           end
       else
           C_count2 = 0;
       end
   end
   in30_1 = sum(flags1(end-180:end));
   in30_2 = sum(flags2(end-180:end));
   in30(q, 1:2) = [in30_1, in30_2];
   in10_1 = sum(flags1(end-60:end));
   in10_2 = sum(flags2(end-60:end));
   in10(q, 1:2) = [in10_1, in10_2];
   beyond30_1 = sum(flags1(1:end-180));
   beyond30_2 = sum(flags2(1:end-180));
   beyond30(q, 1:2) = [beyond30_1, beyond30_2];
   flags1T{q} = flags1;
   flags2T{q} = flags2;
end
end
function plotLines(SOZ,i)
if i >= SOZ-180
   label_1 = {'30 min'};
   xline(SOZ-180, '-.', label_1, LineWidth=4)
end
if i >= SOZ-60
   label_2 = {'10 min'};
   xline(SOZ-60, '-.', label_2, LineWidth=4)
end
if i > SOZ
   label_3 = {'Seizure Onset'};
   xline(SOZ, 'r', label_3, LineWidth=4)
end
if i > SOZ + 44
   label_4 = {'Seizure End'};
   xline(SOZ+44, 'r', label_4, LineWidth=4)
end
end
function plotFlags(Ls, i, F, funct)
x2 = zeros(Ls,4);
y2 = x2;
count = 1;
for j = 1:i
   if j == 1
 
   elseif F(j) == 1
       x2(count,1:4) = [j-1 j j j-1];
       y2(count,1:4) = [0 0 funct(j) funct(j-1)];
       count = count+1;
      
   else
   end
end
for k = 1:count-1
   fill(x2(k,:), y2(k,:),[0.6350 0.0780 0.1840],EdgeColor='none')
end
end
