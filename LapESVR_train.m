function classifier=LapESVR_train(options,data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT:
%           data
%               .X  :n-by-d data matrix, d is the feature dimension and n
%                   is the number of samples     
%               .Y  :n-by-1 label vector, +1 or -1 for labeled data and 0
%                    for unlabeled data
%               .K  :n-by-n kernel matrix. 
%   
%           options
%               .lambda
%               .mu
%               .ev : number of eigenvectors
%--------------------------------------------------------------------------
% OUTPUT:
%           classifier
%               .name : 'LapESVR'
%               .nSV  : number of support vectors
%               .svs  : the indices of support vectors
%               .alpha: the values of dual variable
%               .b    : the value of bias
%               .xsvs: support vectors
%               .options: the options strcut used to train the
%               .traintime: training time in CPU sec.
%               .kernel_evaluation_time: CPU time to calculate the kernel
%                       matrix
%               .qp_solving_time: CPU time to solve the QP problem, which
%                   implemented by modifying the code of LIBSVM
%--------------------------------------------------------------------------
% Author: Lin Chen (chen0631@ntu.edu.sg)
%--------------------------------------------------------------------------
% Please refer to our paper for more details:
%    Laplacian Embedded Regression for Scalable Manifold Regularization
%    Lin Chen, Ivor Wai-Hung Tsang, Dong Xu 
%    IEEE Transactions Neural Netw. Learn. Syst. 23(6): 902-915, June 2012.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t0 = cputime;
if ~isfield(options,'UseBias'),           options.UseBias=1; end
t1 = cputime();
data.U=calc_u(options,data);
data.hatY=calc_y(data.U,data.Y,options.lambda);
kernel_evaluation_time = cputime()-t1;

lab=(data.Y~=0);  unl=~lab;
l = nnz(lab); %number of labeled data
u = nnz(unl); %number of unlabeled data
weight_vector = ones(l+u,1);
weight_vector(lab) = options.C;
weight_vector(unl) = options.C;
if options.PreKernel==false % if kernel K is not precomputed
    t1 = cputime();
    if options.Verbose
        fprintf('Runing svmtrain2...\n');
    end
    %---------------------------------------------------------------------
    % The QP solver adapted from LIBSVM. The feature has two parts: 1) the
    % original feature X and 2) the low dimensional repreentation U. 
    %---------------------------------------------------------------------
    model = svmtrain2(weight_vector, data.hatY, data.X, ...
        sprintf('-s 5 -t 2 -c %f -g %f -m 1000', 1, 1/(2*options.KernelParam.^2)),data.U);
    if options.Verbose
        fprintf('Finishing solving QP (svmtrain2) using %f sec.\n', cputime-t1);
    end
    qp_solving_time = cputime()-t1;
    alpha = model.sv_coef;
    b = -model.rho;
    xsvs = model.SVs;
    svs = find(ismember(data.X, xsvs, 'rows'));
    sec=cputime - t0;
    classifier = saveclassifier('LapESVR', svs, alpha, ...
        data.X(svs,:), b*options.UseBias,options,sec);   
    classifier.kernel_evaluation_time = kernel_evaluation_time;
    classifier.qp_solving_time = qp_solving_time;
    classifier.nSV = length(classifier.alpha);
else % kernel K is precomputed
    t1 = cputime();
    if ~isfield(data, 'K')
        data.K = calckernel(options, data.X);
    end
    %----------------------------------------------------------------------
    % Same as the case when the kernel K is not precomputed. Here, the 3rd
    % argument is replaced by the precomputed kernel and the '-t 2' is
    % replaced by '-t 4'.
    %----------------------------------------------------------------------
    model = svmtrain2(weight_vector, data.hatY, [(1:size(data.K,1))', data.K], ...
        sprintf('-s 5 -t 4 -c %f -g %f -m 1000', 1, options.gamma), data.U);
    qp_solving_time = cputime()-t1;
    alpha = model.sv_coef;
    b = -model.rho;
    svs = model.SVs;
    sec=cputime - t0;
    classifier = saveclassifier('LapESVR',svs,alpha, ...
        data.X(svs,:), b*options.UseBias,options,sec);
    classifier.kernel_evaluation_time = kernel_evaluation_time;
    classifier.qp_solving_time = qp_solving_time;
    classifier.nSV = nnz(classifier.alpha);
end
