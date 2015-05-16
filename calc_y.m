function Y_trans=calc_y(U,Y,lambda)
% compute the transformed label vector
lab=Y~=0;
n=length(Y);
Lambda=zeros(n,1);
Lambda(lab)=lambda;
Y_trans=U*(U'*(Lambda.*Y));
