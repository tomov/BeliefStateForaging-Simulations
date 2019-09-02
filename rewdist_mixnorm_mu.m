function actual_mu = rewdist_mixnorm_rnd(min_dist, mus, max_dist, sigmas, w)

    % mean of mixture of truncated normals

    w = w / sum(w);

    actual_mu = 0;
    for i = 1:length(w)
        actual_mu = actual_mu + w(i) * rewdist_norm_mu(min_dist, mus(i), max_dist, sigmas(i));
    end
