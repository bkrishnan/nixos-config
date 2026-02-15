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
          eamodio.gitlens
        ];
        userSettings = {
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
          "workbench.colorTheme" = "Solarized Light";
          "github.copilot.nextEditSuggestions.enabled" = true;
          "gitlens.ai.modal" = "vscode";
          "git.confirmSync" = false;
        };
      };
    };
  };
}
