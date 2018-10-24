function peerPCvar(dataroot,matroot,useGPU)

nPC = 2.^[0:10];
ndim0 =  1:512;

dall=load(fullfile(dataroot, 'dbspont.mat'));

clf;
%hold all;
lambda = 10; % regularizer

%%
rng('default');
for d = [1:length(dall.db)]
    %%
    dat = load(fullfile(dataroot,sprintf('spont_%s_%s.mat',dall.db(d).mouse_name,dall.db(d).date)));
    if isfield(dat.stat, 'redcell')
        Ff = dat.Fsp(~logical([dat.stat(:).redcell]),:);
        med = dat.med(~logical([dat.stat(:).redcell]),:);
    else
        Ff = dat.Fsp;
        med = dat.med;
    end
    med = med(sum(Ff,2)>0,:);
    Ff = Ff(sum(Ff,2)>0,:);
    fprintf('\nrecording %d\n',d);
    %%
    NN = size(Ff,1);
    % divide X and Y into checkerboard and use every other square
    y = round(med(:,1));
    ymax=max(med);
    ymax = ymax(1);
    nby = floor(ymax / 16);
    ytrain = ([1:2:16]-1) * nby + [1:nby-10]';
    ytrain = ytrain(:)';
    ytrain = repmat(ytrain,NN,1);
    nt= size(ytrain,2);
    ntrain = find(sum(repmat(y,1,nt) == ytrain, 2)>0);
    ytest = ([2:2:16]-1) * nby + [1:nby-10]';
    ytest = ytest(:)';
    ytest = repmat(ytest,NN,1);
    nt = size(ytest,2);
    ntest = find(sum(repmat(y,1,nt) == ytest, 2)>0);
    
    %ntrain = randperm(NN);
    %ntest = ntrain(1:floor(NN/2));
    %ntrain = ntrain(floor(NN/2)+1:end);
    
    %% bin spikes in 1.2 second bins
    if dat.db.nplanes==10
        tbin = 4;
    else
        tbin=3;
    end
    [NN, NT] = size(Ff);
    Ff    = squeeze(mean(reshape(Ff(:,1:floor(NT/tbin)*tbin),...
        NN, tbin, []),2));
    Ff = (Ff - mean(Ff,2));
    NT = size(Ff,2);
    %% divide time in half
    %Ff = randn(size(Ff));
    Lblock = 60;
    fractrain = 0.5;
    [itrain, itest] = splitInterleaved(NT, Lblock, fractrain, 1);
    tic;
    if useGPU
        Ff = gpuArray(single(Ff));
    end
    [utrain,~,~] = Ff(:,itrain);
    
    %%
    vtest1 = utrain(ntrain,1:1024)' * Ff(ntrain,itrain);
    vtest2 = utrain(ntest,1:1024)' * Ff(ntest,itrain);
    
    semilogx(diag(corr(vtest1',vtest2')));
    
    %%
    pctrain = 1:512;
    expvPC=[];
    for j = nPC
        [a, b] = CanonCor2(vtest(itrain,1:j), vtrain(itrain,pctrain),1e-4);
        for k = 1:length(ndim0)
            n=ndim0(k);
            if n<=size(b,2)
                
                vpred    = vtrain(itest,pctrain) *  b(:,1:n) * a(:,1:n)';
                
                % residuals of PCs
                vres   = vtest(itest,1:j) - vpred;
                expvPC(k,j) = 1 - nanmean(nanvar(vres,1,1))/nanmean(nanvar(vtest(itest,1:j),1,1));
            end
        end
    end
        
    clf; 
    plot(expvPC)
    max(expvPC(:))
end


%save(fullfile(matroot,'PCApred.mat'),'results','expv_neurons');


