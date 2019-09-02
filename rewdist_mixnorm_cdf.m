function f = rewdist_mixnorm_cdf(d, min_dist, mus, max_dist, sigmas, w)

    % CDF of mixture of truncated normals, weighted by w


    w = w / sum(w);
    
    f = zeros(size(d));
    for i = 1:length(w)
        f = f + w(i) * rewdist_norm_cdf(d, min_dist, mus(i), max_dist, sigmas(i));
    end


