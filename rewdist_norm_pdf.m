function f = rewdist_norm_pdf(d, mind, mu, maxd, sigma)

    % PDF of truncated Gaussian


    Z = normcdf(maxd, mu, sigma) - normcdf(mind, mu, sigma);
    f = normpdf(d, mu, sigma);
    F = F / Z;

    f(d <= mind) = 0;
    f(d >= maxd) = 0;

    assert(all(f >= 0));


