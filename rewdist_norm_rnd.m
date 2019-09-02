function d = rewdist_norm_rnd(min_dist, mu, max_dist, sigma)

    % draw from truncated normal

    d = mu + sigma * randn(1);
    % loop until rewLocation is within the min/max of rewDistribution
    while d < min_dist || d > max_dist 
        d = mu + sigma * randn(1);
    end
