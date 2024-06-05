# Data Analysis Software

## System requirements
The files were tested in MATLAB R2022b (The MathWorks, USA), on a i7-12700H 2.30 GHz (32 GB RAM) laptop running Windows 64-bit. No errors were encountered (only some warnings sometimes related to the polyshape function of MATLAB, but these can safely be ignored). 

The code was also tested in MATLAB R2023b, and should be working in any version of MATLAB where the polyshape.m function exists (i.e., MATLAB R2017b or newer).
It is advised to have the MATLAB Statistics and Machine Learning and the Curve Fitting Toolboxes to take full advantage of the software package.

## Installation and run guide
To install:
  - Download the full folder to your computer.
  - Add the full folder to your MATLAB path 
  ```
  Option 1: Navigate to the folder through the 'Current Folder' menu and right click -> Add To Path -> Selected Folders and Subfolders
  Option 2: Home tab in MATLAB -> Environment group: Set Path -> Add with Subfolders -> Select the folder in the input dialog -> Save -> Close
  ```
  - Run the 'Data Analysis Software'
  ```
  In the Command Window, type: data_analysis_software
  ```
A typical "installation" should not take you longer than a minute.

The run time on a i7-12700H 2.30 GHz (32 GB RAM) laptop with Windows 64-bit is ~15 minutes. This is to perform the co-localization analysis on an AT8 data set.
For ECLiPSE code, we refer to https://github.com/LakGroup/ECLiPSE.

## More information

Please refer to: Santiago-Ruiz et al. BioRxiv 2024 for more information about this work: DOI: https://doi.org/10.1101/2024.04.24.590893.
