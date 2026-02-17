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
        description = "NixOS rebuild switch";
        body = ''
          sudo nixos-rebuild switch --flake ~/nixos-config#imac
        '';
      };
      
      nrt = {
        description = "NixOS rebuild test";
        body = ''
          sudo nixos-rebuild test --flake ~/nixos-config#imac
        '';
      };

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
