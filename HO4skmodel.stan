data {
  int<lower=1> N;
  int<lower=1> O;
  int<lower=1> F;
  int<lower=1> G;
  int<lower=1> S;
  int<lower=1,upper=O> superking[N];
  int<lower=1,upper=F> family[N];
  int<lower=1,upper=G> genus[N];
  int<lower=1,upper=S> species[N];
  int<lower=1,upper=O> parent_of_family[F];
  int<lower=1,upper=F> parent_of_genus[G];
  int<lower=1,upper=G> parent_of_species[S];
  vector[N] y;
  int<lower=0,upper=1> likelihood;
}
parameters {
  real mu;
  real<lower=0> sigma;
  real<lower=0> tausuperking;
  vector<lower=0>[O] taufamily;
  vector<lower=0>[F] taugenus;
  vector<lower=0>[G] tauspecies;
  vector[O] bsuperking_z;
  vector[F] bfamily_z;
  vector[G] bgenus_z;
  vector[S] bspecies_z;
}
transformed parameters {
  vector[O] bsuperking = bsuperking_z * tausuperking;
  vector[F] bfamily = bfamily_z .* taufamily[parent_of_family];
  vector[G] bgenus = bgenus_z .* taugenus[parent_of_genus];
  vector[S] bspecies = bspecies_z .* tauspecies[parent_of_species];
}
model {
  // non-hierarchical priors
  mu ~ normal(0, 1);
  sigma ~ normal(0, 1);
  tausuperking ~ normal(0, 1);
  taufamily ~ normal(0, 1);
  taugenus ~ normal(0, 1);
  tauspecies ~ normal(0, 1);
  //hierarchical priors
  bsuperking_z ~ normal(0, 1);
  bfamily_z ~ normal(0, 1);
  bgenus_z ~ normal(0, 1);
  bspecies_z ~ normal(0, 1);
  // likelihood
  if (likelihood == 1){
    vector[N] yhat = mu + bsuperking[superking] + bfamily[family] + bgenus[genus] + bspecies[species];
    y ~ normal(yhat, sigma);
  }
}
generated quantities {
  vector[N] log_likelihood;
  vector[N] yrep;
  {
    vector[N] yhat = mu + bsuperking[superking] + bfamily[family] + bgenus[genus] + bspecies[species];
    for (n in 1:N){
      log_likelihood[n] = normal_lpdf(y[n] | yhat[n] , sigma);
      yrep[n] = normal_rng(yhat[n], sigma);
    }
  }
}