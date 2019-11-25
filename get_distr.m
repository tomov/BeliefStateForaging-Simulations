function [pdf, cdf, rnd, mea] = get_distr(distr, min_dist, mu, max_dist, sigma, params)

    % get probability function densities and statistics 
    %
    % e.g. [pdf, cdf, rnd, mea] = get_distr('norm', 20, 140, 500, 80)


    switch distr
        case 'norm'
            pdf = @(d) rewdist_norm_pdf(d, min_dist, mu, max_dist, sigma);
            cdf = @(d) rewdist_norm_cdf(d, min_dist, mu, max_dist, sigma);
            rnd = @() rewdist_norm_rnd(min_dist, mu, max_dist, sigma);
            mea = @(maxd) rewdist_norm_mu(min_dist, mu, maxd, sigma);

        case 'unif'
            pdf = @(d) rewdist_unif_pdf(d, min_dist, max_dist);
            cdf = @(d) rewdist_unif_cdf(d, min_dist, max_dist);
            rnd = @() rewdist_unif_rnd(min_dist, max_dist);
            mea = @(maxd) rewdist_unif_mu(min_dist, maxd);

        case 'mixnorm'
            if ~exist('params', 'var')
                mus = [50 140 250];
                sigmas = [10 10 10];
                w = [3 2 1];
            else
                mus = params.mus;
                sigmas = params.sigmas;
                w = params.w;
            end
            pdf = @(d) rewdist_mixnorm_pdf(d, min_dist, mus, max_dist, sigmas, w);
            cdf = @(d) rewdist_mixnorm_cdf(d, min_dist, mus, max_dist, sigmas, w);
            rnd = @() rewdist_mixnorm_rnd(min_dist, mus, max_dist, sigmas, w);
            mea = @(maxd) rewdist_mixnorm_mu(min_dist, mus, maxd, sigmas, w);

        otherwise
            assert(false);

    end
