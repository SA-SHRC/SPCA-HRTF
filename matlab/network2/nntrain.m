function [optimal_nn, L]  = nntrain(nn, train_x, train_y, opts, val_x, val_y, MAX)
    %NNTRAIN trains a neural net
    % [nn, L] = nnff(nn, x, y, opts) trains the neural network nn with input x and
    % output y for opts.numepochs epochs, with minibatches of size
    % opts.batchsize. Returns a neural network nn with updated activations,
    % errors, weights and biases, (nn.a, nn.e, nn.W, nn.b) and L, the sum
    % squared error for each training minibatch.
    
    assert(isfloat(train_x), 'train_x must be a float');
    % assert(nargin == 4 || nargin == 6,'number ofinput arguments must be 4 or 6')
    
    loss.train.e               = [];
    loss.train.e_frac          = [];
    loss.val.e                 = [];
    loss.val.e_frac            = [];
    opts.validation = 0;
    if nargin == 7
        opts.validation = 1;
    end
    
    fhandle = [];
    if isfield(opts,'plot') && opts.plot == 1
        fhandle = figure();
    end
    
    m = size(train_x, 1);
    
    batchsize = opts.batchsize;
    numepochs = opts.numepochs;
    
    numbatches = m / batchsize;
    
    assert(rem(numbatches, 1) == 0, 'numbatches must be a integer');
    
    L = zeros(numepochs*numbatches,1);
    n = 1;
    minMSE = inf;
    count = 0;
    for i = 1 : numepochs
        tic;
        
        kk = randperm(m);
        for l = 1 : numbatches
            batch_x = train_x(kk((l - 1) * batchsize + 1 : l * batchsize), :);
            
            %Add noise to input (for use in denoising autoencoder)
            if(nn.inputZeroMaskedFraction ~= 0)
                batch_x = batch_x.*(rand(size(batch_x))>nn.inputZeroMaskedFraction);
            end
            
            batch_y = train_y(kk((l - 1) * batchsize + 1 : l * batchsize), :);
            
            nn = nnff(nn, batch_x, batch_y);
            nn = nnbp(nn);
            nn = nnapplygrads(nn);
            
            L(n) = nn.L;
            
            n = n + 1;
        end
        
        t = toc;
    
        if opts.validation == 1
            loss = nneval(nn, loss, train_x, train_y, val_x, val_y);
            str_perf = sprintf('; Full-batch train mse = %.2f, val mse = %.2f', loss.train.e(end), loss.val.e(end));
        else
            loss = nneval(nn, loss, train_x, train_y);
            str_perf = sprintf('; Full-batch train err = %.2f', loss.train.e(end));
        end
        if ishandle(fhandle)
            nnupdatefigures(nn, fhandle, loss, opts, i);
        end
            
        echo = sprintf('epoch %*d/%d. Took %.4f seconds. Mini-batch mean squared error on training set is %.2f%s', length(num2str(opts.numepochs)), i, opts.numepochs, t, mean(L((n-numbatches):(n-1))), str_perf);
        if(i>1 && mod(i-1,100)~=0)
            fprintf(repmat('\b',1,length(prev_echo)));
        else
            fprintf('\n');
        end
        fprintf(echo);
        prev_echo = echo;
        
        if opts.validation == 1
            if loss.val.e(end) < minMSE
                minMSE = loss.val.e(end);
                count = 0;
                optimal_nn = nn;
            else
                count = count +1;
            end
            if count == MAX
                break;
            end
        end
        
        nn.learningRate = nn.learningRate * nn.scaling_learningRate;
    end
    fprintf('\n');
    end
    
    