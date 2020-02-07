Q_learn: use to generate q learning simulations
- csc model learns based on observations
- plotted with plot Q_learn, goes automatically

BQ.m : virtual reality task - very similar with small difference
BQ0.m : clara's task, works with environment 0
- these guys get passed 
each column of the heatmaps are B at a given timepoints

init_env_0 : exactly clara's env
 - goes with next_env_0
init_env_1: our environment, single track.. set probes to 0 to get track 1
 - goes with next_env_1
 - next_env_1 goes along with the track not appearing.. change transition structure
 
 init_params.m : pass all parameters needed for diff exp/set of assumptions
 - clara_task_1_orig : original starkweather POMDP
 - clara_task_1: our POMDP
 -  + _ITI makes observation of ITI visually distinct from ISI

next_env_1.m : every action has two possible 

plot_env : use to generate the graphs
