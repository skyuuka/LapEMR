% setting default paths
compile;
setpaths
fprintf('\nLoading data...\n');
load 2moons; X = [x;xt]; Y = [y;yt]; clear x y;
% generating options
options.Verbose=1;
%== Important parameter for LapESVR
options.C=10;
options.lambda=10^6;
options.mu=10;
options.ev = 2;
%== Parameters related to kernel
options.PreKernel = false; % If your dataset is small, you can set this options to true, which will pre-compute the kernel
options.Kernel = 'rbf';
options.KernelParam = 1; % bandwith parameter of RBF kernel
%== Parameters related to graph construction
options.LaplacianDegree = 1;
options.GraphDistanceFunction = 'euclidean';
options.GraphWeights = 'heat';
options.GraphWeightParam = 0;
options.LaplacianNormalize = 1;
options.NN = 6; 

%== creating the 'data' structure
data.X=X;
data.Y=zeros(size(Y));
pos=[115]; % 1 labeled examples of class +1
neg=[79]; % 1 labeled examples of class -1
data.Y(pos)=1;
data.Y(neg)=-1;

fprintf('Computing Gram matrix and Laplacian...\n\n');
if options.PreKernel
    data.K=calckernel(options,X,X);
end
data.L=laplacian(options,X);

%==  training the classifier
fprintf('Training LapESVR...\n');
classifier=LapESVR_train(options,data);
fprintf('It took %g seconds.\n',classifier.traintime);

%==  computing error rate
out = LapESVR_predict(data, classifier);
%out=sign(data.K(:,classifier.svs)*classifier.alpha+classifier.b);
er=100*(length(data.Y)-nnz(out==Y))/length(data.Y);
fprintf('Error rate=%.1f\n\n',er);


%== Draw the results
close all;
h=figure;
rmin=min(min(data.X))-0.2;
rmax=max(max(data.X))+0.2;
steps=(rmax-rmin)/100;
xrange=rmin:steps:rmax+0.1;
yrange=rmin:steps:rmax+0.1;
plotclassifier(classifier, xrange, yrange);
plot2D(data.X,data.Y);

fontsize = 16;
%title([classifier.name '  ('  options.Kernel  ', \sigma =' num2str(options.KernelParam) ')'], 'FontSize', fontsize);
if options.mu ~=0
    xlabel([' C = ' sprintf('10^{%d}',log10(options.C)) ...
        ' \lambda = ' sprintf('10^{%d}', log10(options.lambda)) ...
        ' \mu = ' sprintf('10^{%d}',log10(options.mu)) ...
        ' n_{ev} = ' num2str(options.ev)], 'FontSize', fontsize);
else
    xlabel([' C = ' sprintf('10^{%d}',log10(options.C)) ...
        ' \lambda = ' sprintf('10^{%d}', log10(options.lambda)) ...
        ' \mu = ' sprintf('%d',options.mu) ...
        ' n_{ev} = ' num2str(options.ev)], 'FontSize', fontsize);
end
set(gca,'FontSize', fontsize);
set(gca,'YLim', [-1.5, 1.5]);
set(gca,'XLim', [-1.5, 2.5]);
