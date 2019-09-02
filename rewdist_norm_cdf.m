function F = rewdist_norm_cdf(d, mind, mu, maxd, sigma)

    % CDF of truncated Gaussian


    Z = normcdf(maxd, mu, sigma) - normcdf(mind, mu, sigma);
    F = normcdf(d, mu, sigma) - normcdf(mind, mu, sigma);
    F = F / Z;

    F(d <= mind) = 0;
    F(d >= maxd) = 1;

    assert(all(F >= 0));
    assert(all(F <= 1));


