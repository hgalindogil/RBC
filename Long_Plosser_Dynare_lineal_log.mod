%-------------------------------------------------------------------------%
% Modelo de Long y Plosser (1983)
% Considera el modelo lineal: variables en logar�tmo
% Este es el modelo log-lineal
% xh = ln x - ln x_ss
% xh es una representaci�n de x_hat
%-------------------------------------------------------------------------%
/*
[1] Autor: Hamilton Galindo
[2] Fecha: Julio 2011, enero 2017
[3] Uso: 
- Este mod es utilizado en el cap�tulo 2 y 3. En el cap�tulo 2, este c�digo 
se usa para  ejemplificar los comandos de Dynare. En el cap�tulo 3
se utiliza para obtener la soluci�n del modelo y los IRF.
[4] Supuestos:
- El modelo de Long y Plosser (1983) supone: depreciaci�n total y
funci�n de utilidad logar�tmica.
[5] Comentarios:
- La calibraci�n corresponde a valores trimestrales y es tomado de
King y Rebelo (2000). "Resuscitating Real Business Cycles".
*/
%============================================
% Nota1: en el archivo mod se puede a�adir comentarios colocando primero % o //. Tambien se puede
% escribir un par�grafo colocando /* al inicio y */ al final. 
%-------------------------------------------------------------------------%
% VARIABLES (8)                                                                        
%-------------------------------------------------------------------------%

var
% este comando (var) es para introducir las variables end�genas
ch   $\widehat{c}_t$ (long_name = 'Consumo')                     %ch = lnc - lnc_ss
ih    $\widehat{i}_t$ (long_name = 'Inversi�n')                       %ih = lni - lni_ss
yh   $\widehat{y}_t$ (long_name = 'Producto')                      %yh = lny - lny_ss
kh   $\widehat{k}_t$ (long_name = 'Capital')                         %kh = lnk - lnk_ss
hh   $\widehat{h}_t$ (long_name = 'Trabajo')                        %hh = lnh - lnh_ss
rh    $\widehat{r}_t$ (long_name = 'Tasa de inter�s real')      %rh = lnr - lnr_ss
wh   $\widehat{w}_t$ (long_name = 'Salario real')                 %wh = lnw - lnw_ss
ah   $\widehat{a}_t$ (long_name = 'Productividad')              %ah = lna - lna_ss
; % al final de este bloque (variables end�genas) se debe de colocar ";"

varexo e $e_t$ (long_name = 'Choque de productividad');
% el comando "varexo" es para introducir las variables ex�genas
%-------------------------------------------------------------------------%
% PARAMETROS ()                                                                         
%-------------------------------------------------------------------------%
parameters
% el comando "parameters" introduce a los par�metros del modelo. Este bloque tambien termina
% con ";"
theta      $\theta$ (long_name = 'peso del ocio en la funci�n de utilidad')
beta       $\beta$ (long_name = 'factor de descuento')
alpha     $\alpha$ (long_name = 'participaci�n del trabajo en el ingreso nacional')
rho         $\rho$ (long_name = 'persistencia del choque')
sigma_ee $\sigma_e$ (long_name = 'des. est. del choque')
y_ss 
c_ss 
i_ss
w_ss
r_ss
k_ss
h_ss
a_ss
;
% Nota2: nunca nombra a la des. est. "sigma_e" debido a que es un nombre 
% propio de Dynare. Si se utiliza Dynare mostrar� un error y no correr� el modelo.
%-------------------------------------------------------------------------%
% CALIBRACI�N                                                                       
%-------------------------------------------------------------------------%
%1)Preferencias
%--------------
h_ss = 0.2;
beta = 0.984;
%2)Empresas
%--------------
alpha = 0.667;
%3)Choques
%--------------
rho = 0.979; 
sigma_ee = 0.0072;
%--------------
% Aqu� recien se calcula theta (debido a que necesitaba que alpha y beta sean previamente definidos):
theta = alpha*(1 - h_ss)/(h_ss*(1 - beta*(1-alpha))); % =3.968
%-------------------------------------------------------------------------%
% ESTADO ESTACIONARIO                                                                    
%-------------------------------------------------------------------------%
r_ss = 1/beta;
a_ss = 1;
k_ss = h_ss*(1/(beta*(1-alpha)))^(-1/alpha);
i_ss = k_ss;
y_ss = k_ss*(1/(beta*(1-alpha)));
c_ss = k_ss*(1/(beta*(1-alpha)) - 1);
w_ss = alpha*y_ss/h_ss;
% Aqui recien acaba el bloque de "parameters"

model(linear);
% El comando "model" hace referencia al modelo DSGE
%================================
% Familias 
%================================
ch =  ch(+1) - rh(+1);
(h_ss/(1-h_ss))*hh = wh - ch;
kh = ih; 
%================================
% Firmas
%================================
yh = ah  + (1-alpha)*kh(-1) + alpha*hh;
rh = yh - kh(-1);
wh = yh - hh;
%================================
% Condici�n de mercado 
%================================
yh = (c_ss/y_ss)*ch + (i_ss/y_ss)*ih;  
%================================
% Fuentes de incertidumbre 
%================================
ah = rho*ah(-1) + e;
end;
%-------------------------------------------------------------------------%
% VALORES INICIALES
%-------------------------------------------------------------------------%
% el bloque "initval" hace referencia a los valores iniciales del modelo
initval;
hh = 0;
kh = 0;
ih = 0;
ch = 0;
wh = 0;
rh = 0;
yh = 0;
ah = 0;
end;
% Este bloque termina con "end"
resid(1);
%El comando "resid(1)" evalua las ecuaciones del modelo para los valores iniciales
steady;
%"steady" pide a dynare que considere los valores inciales como aproximaciones y que las
%simulaciones o IRFs empiecen desde el estado estacionario exacto.
%-------------------------------------------------------------------------%
% CHOQUES                                                                          
%-------------------------------------------------------------------------%
% el bloque "shocks" ...."end" define la varianza del choque
shocks;
var e = (sigma_ee)^2;
end;

check;
%"check" calcula y muestra los valores del sistema, los cuales son usados en el m�todo de soluci�n
%-------------------------------------------------------------------------%
%SIMULACI�N: 
%-------------------------------------------------------------------------%
stoch_simul(order = 1,irf=40);
%este comando instruye a Dynare a calcular: aproximaci�n de Taylor del sistema no-lineal (ecuaciones que componen el modelo),
%los IRFS y estadisticas descriptivas
oo_p_l_log = oo_; 
save oo_p_l_log.mat;