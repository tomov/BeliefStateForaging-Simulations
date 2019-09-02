function actual_mu = rewdist_norm_mu(min_dist, mu, max_dist, sigma)

    % mean of truncated gaussian -- see Moments in https://en.wikipedia.org/wiki/Truncated_normal_distribution 

    alpha = (min_dist - mu) / sigma;
    beta = (max_dist - mu) / sigma;
    actual_mu = mu + sigma * (normpdf(alpha) - normpdf(beta)) / (normcdf(beta) - normcdf(alpha));

    alpha
    beta
    min_dist
    max_dist
    max_dist == min_dist

    if max_dist <= min_dist
        actual_mu = 0;  % doesn't matter; we multiply it by 0 anyway b/c this means no reward (eg agent stops before it reaches the rewarded region); otherwise might be nan
    end

