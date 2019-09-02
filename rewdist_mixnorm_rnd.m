function d = rewdist_mixnorm_rnd(min_dist, mus, max_dist, sigmas, w)

    % draw from mixture of truncated normals, weighted by w

    w = w / sum(w);
    i = find(mnrnd(1, w));
    d = rewdist_norm_rnd(min_dist, mus(i), max_dist, sigmas(i));
