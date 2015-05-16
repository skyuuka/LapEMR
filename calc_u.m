function U = calc_u(options, data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT:
%           data.X  :n-by-d data matrix, d is the feature dimension and n
%                   is the number of samples     
%           data.Y  :n-by-1 label vector, +1 or -1 for labeled data and 0
%                    for unlabeled data
%
%           options.lambda
%           options.mu
%           options.ev : number of eigenvectors
%--------------------------------------------------------------------------
% OUTPUT:
%           U   : the low dimension data representation, \tilde{\Phi} in
%               the paper
%--------------------------------------------------------------------------
% Author: Lin Chen (chen0631@ntu.edu.sg)
%--------------------------------------------------------------------------
% Please refer to our paper for more details:
%    Laplacian Embedded Regression for Scalable Manifold Regularization
%    Lin Chen, Ivor Wai-Hung Tsang, Dong Xu 
%    IEEE Transactions Neural Netw. Learn. Syst. 23(6): 902-915, June 2012.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EPS=0.0001;%
n=size(data.X,1);
lab = find(data.Y~=0);
Lambda=zeros(n,1); Lambda(lab)=options.lambda;
if options.mu==0
    Lambda=Lambda+10^-8;
    U=sparse(1:n, 1:n, 1./sqrt(Lambda));		
else
    t0=cputime;    
    %== compute L
    if isfield(data, 'L')==false
        data.L=laplacian(options,data.X);
    end
    ev=min(options.ev,n);   
    if ev==n
        [U, D] = eig(full(data.L+speye(n)*EPS));
        D=diag(D); D=D-EPS;
        [D,idx]=sort(D); D=diag(D);
        U=U(:,idx);
    else
        [U,D,flag]=eigs(data.L+speye(n)*EPS, ev, 'sm');%EPS is added to avoid singular case
        assert(flag==0);%make sure the solution converges
        D=diag(D); D=D(1:ev);
        D=diag(D);
        U=U(:,1:ev);
    end
    %S = U'*sparse(1:n,1:n, Lambda)*U + options.mu * D;   
    S = options.lambda * (U(lab,:)'*U(lab,:)) + options.mu * D;
    [V,D] = eig(full(S));
    D_half=diag(1./sqrt(diag(D)));
    tildU=U*V*D_half;
    U = tildU;
    if options.Verbose
        fprintf('Run calc_u using %g cpu sec.\n', cputime-t0);
    end
end
