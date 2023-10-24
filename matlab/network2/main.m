
clear;

for i = 1 : 101
    fprintf('\nTraining for frequency bin %d/101', i);
    coeff_training (i);
end