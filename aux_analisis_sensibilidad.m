% Valores del parámetro
rhos = [0.5 0.7 0.9];
for j= 1:size(rhos,2)
rho = rhos(j);
stoch_simul(order=1, irf=40, nograph, nomoments,nofunctions);
oo_sen{j} = oo_; 
end;
% Gráfica
name = {'Consumo', 'Inversión','Producción','Capital','Trabajo','Tasa de interés real', 'Salario', 'Productividad'};
field_name = fieldnames(oo_sen{1}.irfs); time = 1:40;
    for j=1:size(name,2)
        subplot(2,4,j)
        plot(time,oo_sen{1}.irfs.(field_name{j}),...
            time,oo_sen{2}.irfs.(field_name{j}),'--',...
            time,oo_sen{3}.irfs.(field_name{j}),'-.','LineWidth', 1.5)
        title(name{j});
        grid;
    end;
    legend('\rho=0.5', '\rho=0.7', '\rho=0.9');
orient landscape
saveas(gcf,'analisis_sensibilidad','pdf');
    
