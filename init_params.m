function [frac_tr1, frac_pr, ITI_len, init_fn, next_fn, plot_fn, names] = init_params(name)

    switch name
        % original POMDP from Starkweather et al. 2017

        case 'clara_task_1_orig'
            frac_tr1 = 0;
            frac_pr = 0;
            ITI_len = 10;
            sigma = 2;
            init_fn = @() init_env_0(frac_pr, ITI_len, sigma);
            next_fn = @next_env_0;
            plot_fn = @plot_graph_0; 
            names = {'task 1'};

        case 'clara_task_2_orig'
            frac_tr1 = 0;
            frac_pr = 0.2;
            ITI_len = 10;
            sigma = 2;
            init_fn = @() init_env_0(frac_pr, ITI_len, sigma);
            next_fn = @next_env_0;
            plot_fn = @plot_graph_0; 
            names = {'task 1'};

        % Our POMDP adapted to Starkweather et al. 2017 -- separate omission states and rewarded states
        % agent runs all the way to end after reward, like in CSC TD in the paper

        case 'clara_task_1'
            frac_tr1 = 0;
            frac_pr = 0;
            ITI_len = 10;
            sigma = 2;
            init_fn = @() init_env_1(frac_pr, ITI_len, sigma);
            next_fn = @next_env_1_1;
            plot_fn = @plot_graph_1; 
            names = {'task 1'};

        case 'clara_task_2'
            frac_tr1 = 0;
            frac_pr = 0.2;
            ITI_len = 10;
            sigma = 2;
            init_fn = @() init_env_1(frac_pr, ITI_len, sigma);
            next_fn = @next_env_1_1;
            plot_fn = @plot_graph_1;
            names = {'task 2'};

        % Our POMDP adapted to Starkweather et al. 2017, with the differece that the agent enters the ITI after a reward and it knows it

        case 'clara_task_1_ITI'
            frac_tr1 = 0;
            frac_pr = 0;
            ITI_len = 10;
            sigma = 2;
            init_fn = @() init_env_1(frac_pr, ITI_len, sigma);
            next_fn = @next_env_1;
            plot_fn = @plot_graph_1; 
            names = {'task 1'};

        case 'clara_task_2_ITI'
            frac_tr1 = 0;
            frac_pr = 0.2;
            ITI_len = 10;
            sigma = 2;
            init_fn = @() init_env_1(frac_pr, ITI_len, sigma);
            next_fn = @next_env_1;
            plot_fn = @plot_graph_1;
            names = {'task 2'};

        % Our track 2

        case 'track_2'
            frac_tr1 = 0;
            frac_pr = 0.2;
            ITI_len = 10;
            sigma = 2;
            init_fn = @() init_env_1(frac_pr, ITI_len, sigma);
            next_fn = @next_env_1;
            plot_fn = @plot_graph_1;
            names = {'track 2'};

        otherwise 
            assert(false);
    end

