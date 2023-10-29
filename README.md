## This project provides part of the codes used in the IEEE transaction paper: **<a href="https://doi.org/10.1109/TASLP.2020.2967539" target="_blank">Modeling of Individual HRTFs Based on Spatial Principal Component Analysis.</a>**

### The models of the neural networks in MATLAB are provided in the matlab folder.

### Files in the evaluation folder provides the scripts for result processing.

### The structure of the project is as following

```
root dir
|---data # This data can be downloaded form https://www.jianguoyun.com/p/DSk_y-IQyJ_EChjQw5QFIAA
.   |---training data # provides the data for network training
.   |---test data # provides the data for network testing
.   |---net data # provides the output data of the models
.   |---coeff # privides the output data of the models
|---matlab #
.   |---network1 #
.   |---network2 #
.   |---network3 #
.   |---network4 #
|---evaluation #
|---results #
    |---matlab #
        |---hrir #
```
These codes was validated on MATLAB 2021.