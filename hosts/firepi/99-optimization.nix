{
  # https://nlnetlabs.nl/documentation/unbound/howto-optimise/
  # some optimisation options.
  services.unbound.settings.server = {
    # use all CPUs
    num-threads = 4;

    # power of 2 close to num-threads
    msg-cache-slabs = 4;
    rrset-cache-slabs = 4;
    infra-cache-slabs = 4;
    key-cache-slabs = 4;

    # more cache memory, rrset=msg*2
    rrset-cache-size = "100m";
    msg-cache-size = "50m";

    # more outgoing connections
    # depends on number of cores: 1024/cores - 50
    outgoing-range = 206;

    # Larger socket buffer.  OS may need config.
    so-rcvbuf = "4m";
    so-sndbuf = "4m";

    # Faster UDP with multithreading (only on Linux).
    so-reuseport = "yes";
  };
}
