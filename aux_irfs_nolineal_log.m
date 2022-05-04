dynare Long_Plosser_Dynare_nolineal_log;
IRF = [oo_.irfs.cc_e', oo_.irfs.ii_e', oo_.irfs.yy_e', oo_.irfs.kk_e', oo_.irfs.hh_e',oo_.irfs.rr_e', oo_.irfs.ww_e', oo_.irfs.aa_e',];
names = {'Consumo', 'Inversión', 'Producto', 'Capital', 'Trabajo', 'Tasa de interés', 'Salario real', 'Productividad'};
for i=1:size(IRF,2)
    subplot(2,4,i)
    plot(IRF(:,i),'LineWidth', 1.5);
    title(names{i});
    grid;
end
orient landscape
saveas(gcf,'ifrs_nolineal_log_matlab','pdf');