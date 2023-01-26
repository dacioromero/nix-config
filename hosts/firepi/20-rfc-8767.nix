{
  # https://unbound.docs.nlnetlabs.nl/en/latest/topics/core/serve-stale.html
  services.unbound.settings.server = {
    serve-expired = "yes";
    serve-expired-ttl = 86400;
    serve-expired-client-timeout = 1800;
  };
}
