function res=psomethod(fun,X0,C,np,niter,Xini,salvar,ndisp,voidxpg)
% Funcion "psomethod", Version 2.1
% ///////////////////////////////////////////////////////////////////
% Funcion que aplica el algoritmo PSO (Particle Swarm Optimization) para
% la optimizacion de funciones de n varibales dependientes y una salida
% escalar. Esta actualización permite guardar mediciones de cada simulacion
% que se probo.
% ///////////////FUNCION DESARROLLADA POR R. RUIZ-CRUZ//////////
%
% res=psomethod(fun,X0,C,np,niter,Xini,salvar,ndisp,voidxpg)
%
% Parametros de Entrada:
% "fun", apuntador de la funcion a optimizar (@rastrigin)
% "X0", vector o matriz de limites de busqueda iniciales
%
% %%%%% Parametros opcionales %%%%%
% "C", vector de velocidades de movimiento para las particulas (default C = [0.1 0.1])
% "np", numero de particulas que realizaran la busqueda (default np = 100)
% "niter", numero de iteraciones que realizara el algoritmo (default niter = 1000)
% "Xini", solucion que se desea agregar al enjambre inicial (solucion conocida)
% "salvar", "none", "gbest","lbest","all", indicador que activa el respaldo del enjambre
%           en un archivo .mat
% "ndisp", indica cada cuantas generaciones imprimira el progreso en la
%          terminal(util para cuando se quiere saber si algoritmo sigue ejecutandose)
% "voidxpg", 'true' para evitar que el lider se ejecute si no se ha
%           actualizado, 'false' si no importa que se ejecute el lider aun
%           cuando aÃºn no se haya actualizado por otro mejor. Esto puede 
%           ayudar cuando la evaluacion de la funcion tarda mucho tiempo.
%
% #Descripcion de entrada#
% La definicion de las variables debes tener la siguiente estructura.
% Una variable:
%       #funcion a minimizar#
%       function y = rast1(X)
%       x1=X;
%       try
%           y= 10+x1.^2-10*cos(5*x1);
%       catch
%           print('Some error occurs in the function objective')
%       end
%
%       #Ejemplo#
%       X0 = [7 8];
%       np = 10000;
%       niter = 100;
%       C = [0.1 0.1];
%       Xini = [10];
%       res = psomethod(@rast1,X0,C,np,niter,Xini,'none')
%
% Dos o mas variables:
%       #funcion a minimizar#
%       function y = rast2(X)
%       x1=X(:,1);
%       x2=X(:,2);
%       y= 10+x1.^2-10*cos(5*x1)+x2.^2-10*cos(5*x2);
%
%       #Ejemplo#
%       X0 = [7 8; 7 8];
%       np = 10000;
%       niter = 100;
%       C = [0.1 0.1];
%       Xini = [2 1];
%       res = psomethod(@rast2,X0,C,np,niter,Xini,'none')
%
% Parametros de Salida:
% "res", estructura con los resultados de la optimizacion.}
% "res.xbest", Vector de los mejores valores encontrados
% "res.fbest", desempeno de los mejores valores encontrados
% 
%       #Ejemplo#
%       res = 
%       
%           xbest: [2.0352e-004 -7.1232e-004]
%           fbest: -9.9999
%
% Version 2: Evita que el lider se vuelva a evaluar si es que no se ha
% actualizado aun. Esto ayuda a que se redusca el numero de veces que el
% lider se evalua y disminuye la carga carga computacional
%
% Version 1.8: Implementa la seleccion del numero de generaciones
% necesarias para imprimir un valor en la pantalla 

% Verificando que los parametros que se introducjeron sean correctos
if (nargin >= 2)
    if ~exist('C','var')
        C = [0.1 0.1];
        disp('Velocidad de convergencia default: C = [0.1 0.1]');
    end
    if ~exist('np','var')
        np = 100;
        disp('Numero de particulas default: np = 100');
    end
    if ~exist('niter','var')
        niter = 1000;
        disp('Numero de iteraciones default: niter = 1000')
    end
    if ~exist('salvar','var')
        salvar = 'false';
        disp('No guardar los datos: salvar = ''false''')
    end
    if ~exist('ndisp','var')
        ndisp = round(niter/10);
        disp(fprintf('Visualizacion cada %d',ndisp))
    end
    if ~exist('voidxpg','var')
        voidxpg = false;
    end
end

disp(' ')
disp('%%')
disp('Iniciando el algoritmo')
disp('%%')
disp(' ')

tic;

% Generando las condiciones iniciales aleatorias
nvar = size(X0,1);
Xp=zeros(np,nvar);
for k = 1:nvar
    Xp(:,k)=(X0(k,2)-X0(k,1))*rand(np,1)+X0(k,1);
end

% Si existen condiciones iniciales deseadas, sustituyen a las alaeatorias
if exist('Xini','var')
    if (size(Xini,2)==size(Xp,2))&&(size(Xini,1)<=size(Xp,1))
        for k = 1:size(Xini,1)
            Xp(k,:) = Xini(k,:);
        end
    else
        disp(' ')
        disp('%%')
        disp('Se descarto la solucion inicial propuesta, porque no cuenta con el mismo numero de variables.')
        disp('%%')
        disp(' ')
    end
end 

%global Xpg fxpg
Xpg=zeros(1,nvar);
Xpl=Xp;
VX=zeros(np,nvar);

fxpg=10000000; %valor inicial de desempeno del mejor global
fxpl=ones(np,1)*fxpg; %desempeno de los mejores locales

c1=C(1);
c2=C(2);

%Variables para guardar la evolucion del algoritmo
fxpg_hist = ones(niter,1)*fxpg;
xpg_hist = zeros(niter,nvar);
fxpl_hist = ones(niter,np)*fxpg;
xpl_hist = zeros(np,nvar,niter);
fp_hist = ones(niter,np)*fxpg;
xp_hist = zeros(np,nvar,niter);

% Elegir todos los puntos a evaluar la primera vez
idx = zeros(np,1);
fx = ones(np,1)*fxpg;

for k=1:niter
    % evaluacion de la funcion a minimizar
    fx(~idx,:) = fun(Xp(~idx,:));

    %mejor global
    [val,ind]=min(fx);
    if val<fxpg
        fxpg=val;
        Xpg = Xp(ind,:);
    end

    %mejores locales
    for p=1:np
        if fx(p,1)<fxpl(p,1)
            fxpl(p,1)=fx(p,1);
            Xpl(p,:)=Xp(p,:);
        end
    end
    
    fxpg_hist(k,1) = fxpg;
    xpg_hist(k,:) = Xpg;
    fxpl_hist(k,:) = fxpl';
    xpl_hist(:,:,k) = Xpl;
    fp_hist(k,:) = fx';
    xp_hist(:,:,k) = Xp;
    
    % Decision de la informacion a guardar
    switch salvar
        case 'gbest'
            save 'pso_hist' fxpg_hist xpg_hist
        case 'lbest'
            save 'pso_hist' fxpg_hist xpg_hist fxpl_hist xpl_hist
        case 'all'
            save 'pso_hist' fxpg_hist xpg_hist fxpl_hist xpl_hist fp_hist xp_hist
    end
    
    % Evaluacion de ecuaciones de movimiento
    for n= 1:nvar
        VX(:,n)= VX(:,n)+c1*rand(np,1).*(Xpg(:,n)-Xp(:,n))+c2*rand(np,1).*(Xpl(:,n)-Xp(:,n));
        Xp(:,n)=Xp(:,n)+VX(:,n);
    end
    
    % Determinacion si el mejor global se ha actualizado, sino mejor no
    % evaluarlo
    if voidxpg
        idx = (sum((Xp == ones(np,1)*Xpg),2)==nvar);
        if sum(idx>0)
            fx(idx,:) = fxpg;
            Xp(idx,:) = Xpg;
        end
    end
    
    if mod(k,ndisp) == 0
        disp(['Iter = ' num2str(k) ', Desempeno = ' num2str(fxpg) ', Xpg = ' num2str(Xpg)])
    end

end

res.xbest=Xpg;
res.fbest=fxpg;
res.fbest_hist = fxpg_hist;
res.xbest_hist = xpg_hist;
res.flbest_hist = fxpl_hist;
res.xlbest_hist = xpl_hist;
res.fswarm_hist = fp_hist;
res.xswarm_hist = xp_hist;
toc;