{ ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      fastfetch
    '';

    shellAliases = {
      fetch = "fastfetch";
    };
    
    functions = {
      nr = {
        description = "NixOS rebuild switch with Emacs daemon restart";
        body = ''
          sudo nixos-rebuild switch --flake ~/nixos-config#imac
          and pkill -9 emacs 2>/dev/null
          and emacs --daemon &
        '';
      };
      
      nrt = {
        description = "NixOS rebuild test with Emacs daemon restart";
        body = ''
          sudo nixos-rebuild test --flake ~/nixos-config#imac
          and pkill -9 emacs 2>/dev/null
          and emacs --daemon &
        '';
      };
    };
  };
}
