
x=1:100

m=2
b=10
z=rand(1,100)*20

y=m*x+b+z

n=size(y,2)
hold all
plot(x,y)

res=psomethod(@(X)error_mape(X,y),[5 6;20 30])
plot(res.xbest(1)*x+res.xbest(2))
legend('real','simulacion')