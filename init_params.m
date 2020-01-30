function [frac_tr1, frac_pr, ITI_len, init_fn, next_fn, plot_fn] = init_params(name)

    switch name
        case 'clara_task_1'
            frac_tr1 = 0;
            frac_pr = 0;
            ITI_len = 10;
            sigma = 2;
            init_fn = @() init_env_1(frac_pr, ITI_len, sigma);
            next_fn = @next_env_1_1;
            plot_fn = @plot_graph_1;

        case 'clara_task_2'
            frac_tr1 = 0;
            frac_pr = 0.2;
            ITI_len = 10;
            sigma = 2;
            init_fn = @() init_env_1(frac_pr, ITI_len, sigma);
            next_fn = @next_env_1_1;
            plot_fn = @plot_graph_1;

        otherwise 
            assert(false);
    end

