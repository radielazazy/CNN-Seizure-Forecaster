addpath("C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Patient Data\Clean_Data")
%edf to array
tt = edfread('PN00-1.ICA4.edf');
info = edfinfo('PN00-1.ICA4.edf');
X = cell2mat(table2array(tt));
fs = 512;
t0 = (1:length(X))./fs;
X2 = X(1144*fs+1:1214*fs, 1:29);
%%
% time parameters
[X1, X2, X3, X4] = get_Times(X, 50, 60, 1150, 1160, 1134, 1144, 1215, 1225, fs);
%%
%Parameters%
noverlap = fs/16;
window0 = 2*noverlap;
window = hamming(window0);
nfft2 = noverlap*2;
figure;
[pxx, f] = pwelch(X2, window,noverlap,nfft2,fs);
plot(f, 10*log10(pxx), 'LineWidth', 2);
xlim([2 90]);
legend(info.SignalLabels,'Location', 'bestoutside','Fontsize', 14);
ylabel('Power Spectral Density (\muvolt^2 / Hz )'); xlabel('Frequency (Hz)');
title("Power Spectral Density of Ictal Event")
set(gca, 'fontsize', 20)
%%
figure;
hold on;
for i = 1:length(X2)
   [pxx, f] = pwelch(i, window,noverlap,nfft2,fs);
   plot(f, 10*log10(pxx), 'LineWidth', 2);
end
hold off;
%%
[pxx1, f1] = pwelch(X1, window,noverlap,nfft2,fs);
[pxx2, f2] = pwelch(X2, window,noverlap,nfft2,fs);
[pxx3, f3] = pwelch(X3, window,noverlap,nfft2,fs);
[pxx4, f4] = pwelch(X4, window,noverlap,nfft2,fs);
figure;
plot(f1, 10*log10(pxx1), 'LineWidth', 5, 'DisplayName', 'Inter-ictal'); hold on;
plot(f3, 10*log10(pxx3), 'LineWidth', 5, 'DisplayName','Pre-ictal'); hold on;
plot(f2, 10*log10(pxx2), 'LineWidth', 5, 'DisplayName','Ictal'); hold on;
plot(f4, 10*log10(pxx4), 'LineWidth', 5, 'DisplayName','Post-ictal'); hold on;
ylabel('Power Spectral Density (\muvolt^2 / Hz )'); xlabel('Frequency (Hz)');
title("Power Spectral Density of Stages of Focal Epilepsy")
set(gca, 'fontsize', 20)
legend('Location', 'Northwest','Fontsize', 20);
xlim([5 90])
%% Differences in Power based on subbands Inter vs. Ictal
tt = edfread('PN00-1.ICA4.edf','SelectedSignals', 'T4', 'DataRecordOutputType','vector');
X = cell2mat(table2array(tt));
fs=512;
[X1,X2,X3,X4] = get_Times(X, 90, 100, 1180, 1190, 844, 854, 1514, 1524, fs);
delta = [1 4];
theta = [4 8];
alpha = [8 12];
beta = [12 30];
gamma = [30 90];
d1 = bandpower(X2, fs, delta) - bandpower(X1, fs, delta);
d2 = bandpower(X3, fs, delta) - bandpower(X1, fs, delta);
d3 = bandpower(X4, fs, delta) - bandpower(X1, fs, delta);
t1 = 10*log10(bandpower(X2, fs, theta) - bandpower(X1, fs, theta));
t2 = 10*log10(bandpower(X3, fs, theta) - bandpower(X1, fs, theta));
t3 = 10*log10(bandpower(X4, fs, theta) - bandpower(X1, fs, theta));
a1 = 10*log10(bandpower(X2, fs, alpha) - bandpower(X1, fs, alpha));
a2 = 10*log10(bandpower(X3, fs, alpha) - bandpower(X1, fs, alpha));
a3 = 10*log10(bandpower(X4, fs, alpha) - bandpower(X1, fs, alpha));
b1 = 10*log10(bandpower(X2, fs, beta) - bandpower(X1, fs, beta));
b2 = 10*log10(bandpower(X3, fs, beta) - bandpower(X1, fs, beta));
b3 = 10*log10(bandpower(X4, fs, beta) - bandpower(X1, fs, beta));
g1 = 10*log10(bandpower(X2, fs, gamma) - bandpower(X1, fs, gamma));
g2 = 10*log10(bandpower(X3, fs, gamma) - bandpower(X1, fs, gamma));
g3 = 10*log10(bandpower(X4, fs, gamma) - bandpower(X1, fs, gamma));
figure
x = ["Before" "Seizure" "After"];
y = [t2, a2, b2, g2; t1, a1, b1, g1; t3, a3, b3, g3];
b = bar(x,y);
legend({'Theta', 'Alpha', 'Beta', 'Gamma'},'Fontsize', 20);
title('Subband Power Differences in Seizure Events vs. Inter-ictal')
set(gca, 'fontsize', 15);
ylabel('Power Difference (dB)');
%%
b2 = bar(nexttile,x,y,'stacked');
b2(1).FaceColor = [0.9290 0.6940 0.1250];
b2(2).FaceColor = [0.8500 0.3250 0.0980];
b2(3).FaceColor = [0.4940 0.1840 0.5560];
ylabel('Power Spectral Density (\muvolt^2 / Hz )');
set(gca, 'fontsize', 15);
%% Alternate (simplified)
x1 = ["Delta (1 - 4)Hz" "Theta (4 - 8)Hz" "Alpha (8 - 12)Hz" "Beta (12 - 30)Hz" "Gamma (30 - 90)Hz"];
y1 = [d1 t1 a1 b1 g1];
figure;
bar(x1,y1);
title('Power Differences by Brain Wave Subbands (Seizure vs. Non-seizure)')
set(gca, 'fontsize', 15);
ylabel('Power Spectral Density (\muvolt^2 / Hz )');
%%
function [X1,X2,X3,X4] = get_Times(X, non_0, non_n, inter_0, inter_n, pre_0, pre_n, post_0, post_n, fs)
   X1 = X(non_0*fs+1:non_n*fs); % (no seizure)
   X2 = X(inter_0*fs+1:inter_n*fs); % inter-ictal
   X3 = X(pre_0*fs+1:pre_n*fs); % pre-ictal
   X4 = X(post_0*fs+1:post_n*fs); % post-ictal
end
