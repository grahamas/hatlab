
load('rs1050225_clean_SNRgt4.mat')
load('rs1050225_MI_clean_LFP.mat')
load('rs1050225_MI_SpikeData.mat')
load('beh.mat')

'combine'
combine_all_units
'main'
main_analysis
'new_regimes'
new_regimes
'ppcs'
calc_regime_ppc
'columns'
get_analysis_columns

