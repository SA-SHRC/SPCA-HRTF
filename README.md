## This project provides part of the codes used in the IEEE transaction paper: **[Modeling of Individual HRTFs Based on Spatial Principal Component Analysis.](https://doi.org/10.1109/TASLP.2020.2967539)**

### The neural networks of the spatial principal component analysis (SPCA) based individual HRTFs modeling.

#### network1 *`The network to predict basises of the spatial principal components(SPCs)`*
- Input: reference basis at direction (theta = 0, phi = 0) + theta + phi
- Output: basis of the PCs at direction (theta, phi)

#### network2 *`The network to predict coefficients of the PCs`*
- Input: The eight anthropometric parameters
- Output: coefficients for the PCs

There are totally 101 networks for all the frequency bins. (FFT length is 200)

#### network3 *`The network to predict the Hav, i.e., logrithm-domain head-related transfer function(HRTF)  magnitudes averaged across the frequencies and subjects.`*
- Input: reference Hav at direction (theta = 0, phi = 0) + theta + phi
- Output: Hav at direction (theta, phi)

#### network4 *`The network to predict interaural time difference (ITD) of the subjects`*
- Input: three anthropometric parameters of the head of individual $s_m$ + theta + phi
- Output: ITD of individual $s_m$ at direction (theta, phi)

### The duplicated files in the four network folders are provide for neural network training. The files are listed as below.
- nnapplygrads.m
- nnbp.m
- nneval.m
- nnff.m
- nnpredict.m
- nnsetup.m
- nntrain.m
- nnupdatefigures.m
- normalize.m
- sigm.m
- tanh_opt.m

### Data for the codes can be downloaded from [here](https://www.jianguoyun.com/p/DSk_y-IQyJ_EChjQw5QFIAA)