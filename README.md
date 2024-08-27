****Introduction to Project****

For a more comprehensive report, I refer you to [this file](https://github.com/radielazazy/CNN-Seizure-Forecaster/blob/main/CNN-Seizure-Forecaster-Report.pdf).

Goal: using raw EEG data that contains both seizure and non seizure data, create a model that produces an alert thirty minutes before a seizure occurs. The pipeline involves first, filtering the data, then transforming the data and feeding it into a VGG-16 convolutional neural network, and finally taking likelihood estimations to create a forecaster. This project took about a year of consistent work to complete.

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

****1) Downloading scalp EEG data:**** [Siena Scalp EEG Data](https://physionet.org/content/siena-scalp-eeg/1.0.0/)


****2) Data Processing**** - this involves filtering much of the artifacts out of the original data. Once this has been completed, the data is split into ictal (seizure) and pre-ictal (non-seizure) using timestamps provided by the original datase. The data is labelled to prepare for the CNN training.

  ![Screenshot 2024-08-27 021140](https://github.com/user-attachments/assets/d584db19-9e5b-4ca4-aae9-a2b125e4d521)

  [PSDandSUBBANDS](https://github.com/radielazazy/CNN-Seizure-Forecaster/blob/main/PSDandSUBBANDS.m) - this file filters and splits the data into seizure and nonseizure data.

****3) Classification**** - first, the data was transformed into Continuous Wavelet Transforms (CWT), then the data was used to train the VGG-16 framework to classify whether a specific CWT is in a seizure or non seizure state.

  ![Screenshot 2024-08-27 152803](https://github.com/user-attachments/assets/4ba9a576-8021-42fe-bde9-2667402e8511)

The [CWTs](https://github.com/radielazazy/CNN-Seizure-Forecaster/blob/main/CWTs.m) code transforms the EEG time-frequency data into Continuous Wavelet Transforms.

The [CNNTraining file](https://github.com/radielazazy/CNN-Seizure-Forecaster/blob/main/CNNTraining.m) trains the CNN on seizure and non-seizure data. Votes whether a specific CWT is in a seizure state or not and gives a confidence score associated with the CWT.

**** 4)Forecasting**** - this is where the prediction of the seizure occurs. Topographical maps were created (optional). The CWTs were rearranged based on their respective times. The trained CNN is now able to identify each image as seizure or non-seizure. Likelihood estimations and probability distributions based on the confidence score of the CNN were produced. Kurtosis was used as the main method of determining whether a seizure would occur within the next thirty minutes. After testing many statistical methods, kurtosis seemed to be the most accurate and compatible with our constraints.

The [TopographicalMaps](https://github.com/radielazazy/CNN-Seizure-Forecaster/blob/main/TopographicalMaps.m) code creates topographical maps.















