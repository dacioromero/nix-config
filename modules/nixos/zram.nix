{
  # Many distros enable this by default
  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;
  # https://www.kernel.org/doc/html/next/admin-guide/sysctl/vm.html
  # https://haydenjames.io/linux-performance-almost-always-add-swap-part2-zram/
  # https://www.reddit.com/r/Fedora/comments/mzun99/new_zram_tuning_benchmarks/
  # https://github.com/pop-os/default-settings/pull/163
  # https://github.com/AlexMekkering/Arch-Linux/blob/master/docs/installation/optimizations.md
  # zram is relatively cheap, prefer swap
  boot.kernel.sysctl."vm.swappiness" = 180;
  # zram is in memory, no need to readahead
  boot.kernel.sysctl."vm.page-cluster" = 0;
  # Start asynchronously writing at 128 MiB dirty memory
  boot.kernel.sysctl."vm.dirty_background_bytes" = 128 * 1024 * 1024;
  # Start synchronously writing at 50% dirty memory
  # boot.kernel.sysctl."vm.dirty_ratio" = 50;
  boot.kernel.sysctl."vm.dirty_bytes" = 64 * 1024 * 1024;
  boot.kernel.sysctl."vm.vfs_cache_pressure" = 500;
  # Found in Pop! OS, source https://www.reddit.com/r/linux_gaming/comments/vla9gd/comment/ie1cnrh/
  boot.kernel.sysctl."vm.watermark_boost_factor" = 0;
  boot.kernel.sysctl."vm.watermark_scale_factor" = 125;
}
