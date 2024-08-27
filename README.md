****Introduction to Project****

Goal: using raw EEG data, create a model that produces an alert 30 minutes before a seizure occurs.

Currently, EEG is primarily used for seizure classification
and not prediction. The project leverages noninvasive
scalp-EEG data to develop a model that can alert
patients and assist medical professionals in predicting
epileptic seizures before they happen. Classification and
forecasting modules were implemented in MATLAB,
including time-frequency maps, statistical modeling,
signal processing, and machine learning. The proposed
design achieves a classification accuracy of
approximately 70% and a forecasting precision of 74.3%
thirty minutes before seizure onset, enhancing patient
quality of life without invasive procedures, medication,
or clinical information.


****Step by step guide****

1) Downloading scalp EEG data: [Siena Scalp EEG Data](https://physionet.org/content/siena-scalp-eeg/1.0.0/)


2) Data Processing

![Screenshot 2024-08-27 021140](https://github.com/user-attachments/assets/d584db19-9e5b-4ca4-aae9-a2b125e4d521)

[PSDandSUBBANDS](https://github.com/radielazazy/CNN-Seizure-Forecaster/blob/main/PSDandSUBBANDS.m) file filters and splits the data.



