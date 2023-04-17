{
  obsidian = final: prev: {
    obsidian = prev.obsidian.override {
      electron = prev.electron_22;
    };
  };
}
