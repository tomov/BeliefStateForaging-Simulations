function actual_mu = rewdist_norm_mu(min_dist, mu, max_dist, sigma)

    % mean of truncated gaussian -- see Moments in https://en.wikipedia.org/wiki/Truncated_normal_distribution 

    alpha = (min_dist - mu) / sigma;
    beta = (max_dist - mu) / sigma;
    actual_mu = mu + sigma * (normpdf(alpha) - normpdf(beta)) / (normcdf(beta) - normcdf(alpha));

    % of prob mass of points in interval is 0, treat as uniform TODO think carefully
    if isnan(actual_mu)
        assert(normcdf(beta) == normcdf(alpha));
        actual_mu = mean(min_dist + max_dist);
    end

    if max_dist <= min_dist
        actual_mu = 0;  % doesn't matter; we multiply it by 0 anyway b/c this means no reward (eg agent stops before it reaches the rewarded region); otherwise might be nan
    end

