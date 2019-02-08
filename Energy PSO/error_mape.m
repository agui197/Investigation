function mape=error_mape(X,Y)
    n=size(Y,2);
    x=[1:n];
    M=X(:,1);
    B=X(:,2);
    y_gorro=M*x+B*ones(1,n);
    mape=sum(abs((ones(size(X,1),1)*Y-y_gorro)./(ones(size(X,1),1)*Y)),2)*100/n;
end