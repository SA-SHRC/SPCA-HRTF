### The neural networks of the spatial principal component analysis (SPCA) based individual HRTFs modeling.

#### network1 *`The network to predict basis of the spatial principal components(SPCs)`*
- Input: reference basis at direction (theta = 0, phi = 0) + theta + phi
- Output: the basis of the PCs at the direction (theta, phi)

#### network2 *`The network to predict coefficients of the PCs`*
- Input: The eight anthropometric parameters
- Output: coefficients for the PCs

There are a total of 101 networks for all the frequency bins. (FFT length is 200)

#### network3 *`The network to predict the Hav, i.e., logarithm-domain head-related transfer function(HRTF)  magnitudes averaged across the frequencies and subjects.`*
- Input: reference Hav at direction (theta = 0, phi = 0) + theta + phi
- Output: Hav at the direction (theta, phi)

#### network4 *`The network to predict interaural time difference (ITD) of the subjects`*
- Input: three anthropometric parameters of the head of individual $s_m$ + theta + phi
- Output: ITD of individual $s_m$ at the direction (theta, phi)

### The duplicated files in the four network folders are provided for neural network training. The files are listed below.
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

### Data for the codes can be downloaded from <a href="https://www.jianguoyun.com/p/DSk_y-IQyJ_EChjQw5QFIAA" target="_blank">here</a>.

### reconsMain.m
Reconstructing HRIRs for the train and test dataset using predicted SPCs, coefficents, and so on.

### reconsOri.m
Reconstructing HRIRs for the train and test dataset using the ground truth.

### reconsSubs.m
Reconstructing HRIRs for the train and test dataset for subjects in the subjective experiments.