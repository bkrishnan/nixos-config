{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          ms-vscode.cpptools
          ms-python.python
          golang.go
          rust-lang.rust-analyzer
        ];
        userSettings = {
          "workbench.colorTheme" = "Solarized Light";
          "github.copilot.nextEditSuggestions.enabled" = true;
        };
      };
    };
  };
}
