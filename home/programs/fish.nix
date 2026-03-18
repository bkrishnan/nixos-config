{...}: {
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
    '';

    shellAliases = {
      ff = "fastfetch";
      nr = "sudo nixos-rebuild switch --flake ~/nixos-config#imac";
      nrt = "sudo nixos-rebuild test --flake ~/nixos-config#imac";
      slog = "journalctl -u sanoid -u sanoid-prune.service -u syncoid -f";
      smon = "sudo sanoid --monitor-snapshots | tr , '\n'";
    };

    functions = {
      er = {
        description = "Emacs daemon restart";
        body = ''
          and pkill -9 emacs 2>/dev/null
          and emacs --daemon &
        '';
      };
    };
  };
}
