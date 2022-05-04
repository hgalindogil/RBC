%-------------------------------------------------------------------------%
% Modelo de Long y Plosser (1983)
% Considera el modelo lineal: variables en niveles
% xt = x - x_ss
% xt es una representación de x_tilde
%-------------------------------------------------------------------------%
/*
[1] Autor: Hamilton Galindo
[2] Fecha: Julio 2011, enero 2017
[3] Uso: 
 - Este código es utilizado en el capítulo 2 y 3. En el capítulo 2, este 
código se usa para  ejemplificar los comandos de Dynare. En el capítulo 3
se utiliza para obtener la solución del modelo y los IRF.
Supuestos:
- El modelo de Long y Plosser (1983) supone: depreciación total y
función de utilidad logarítmica.
[4] Comentarios:
- La calibración corresponde a valores trimestrales y es tomado de
King y Rebelo (2000). "Resuscitating Real Business Cycles".
*/
%============================================
% Nota1: en el archivo mod se puede añadir comentarios colocando primero % o //. Tambien se puede
% escribir un parágrafo colocando /* al inicio y */ al final. 
%-------------------------------------------------------------------------%
% VARIABLES (8)                                                                        
%-------------------------------------------------------------------------%

var
% este comando (var) es para introducir las variables endógenas
ct   $\widetilde{c}_t$ (long_name = 'Consumo')                     %consumo
it    $\widetilde{i}_t$ (long_name = 'Inversión')                       %inversión
yt   $\widetilde{y}_t$ (long_name = 'Producto')                      %producto
kt   $\widetilde{k}_t$ (long_name = 'Capital')                         %capital
ht   $\widetilde{h}_t$ (long_name = 'Trabajo')                        %trabajo
rt    $\widetilde{r}_t$ (long_name = 'Tasa de interés real')      %renta de alquiler de capital
wt   $\widetilde{w}_t$ (long_name = 'Salario real')                 %salario real
at   $\widetilde{a}_t$ (long_name = 'Productividad')              %productividad
; % al final de este bloque (variables endógenas) se debe de colocar ";"

varexo e $e_t$ (long_name = 'Choque de productividad');
% el comando "varexo" es para introducir las variables exógenas
%-------------------------------------------------------------------------%
% PARAMETROS ()                                                                         
%-------------------------------------------------------------------------%
parameters
% el comando "parameters" introduce a los parámetros del modelo. Este bloque tambien termina
% con ";"
theta      $\theta$ (long_name = 'peso del ocio en la función de utilidad')
beta       $\beta$ (long_name = 'factor de descuento')
alpha     $\alpha$ (long_name = 'participación del trabajo en el ingreso nacional')
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
% propio de Dynare. Si se utiliza Dynare mostrará un error y no correrá el modelo.
%-------------------------------------------------------------------------%
% CALIBRACIÓN                                                                       
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
% Aquí recien se calcula theta (debido a que necesitaba que alpha y beta sean previamente definidos):
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
ct = beta*(r_ss*ct(+1) - c_ss*rt(+1));
kt = it;
wt = (w_ss/(1-h_ss))*ht + (theta/(1-h_ss))*ct;
%================================
% Firmas
%================================
yt = (y_ss/a_ss)*at + (1-alpha)*(y_ss/k_ss)*kt(-1) + alpha*(y_ss/h_ss)*ht;
(y_ss/k_ss)*kt(-1) =  yt - (k_ss/(1-alpha))*rt;
wt = (alpha/h_ss)*yt - ((alpha*y_ss)/(h_ss)^2)*ht;
%================================
% Condición de mercado 
%================================
yt = ct + it;  
%================================
% Fuentes de incertidumbre 
%================================
at = rho*at(-1) + e;
end;
%-------------------------------------------------------------------------%
% VALORES INICIALES
%-------------------------------------------------------------------------%
% el bloque "initval" hace referencia a los valores iniciales del modelo
initval;
ht = 0;
kt = 0;
it = 0;
ct = 0;
wt = 0;
rt = 0;
yt = 0;
at = 0;
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
%"check" calcula y muestra los valores del sistema, los cuales son usados en el método de solución
%-------------------------------------------------------------------------%
%SIMULACIÓN: 
%-------------------------------------------------------------------------%
stoch_simul(order = 1,irf=40);
%este comando instruye a Dynare a calcular: aproximación de Taylor del sistema no-lineal (ecuaciones que componen el modelo),
%los IRFS y estadisticas descriptivas
oo_p_l_niv = oo_; 
save oo_p_l_niv.mat;