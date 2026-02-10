{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.cpptools
      ms-python.python
      golang.go
      rust-lang.rust-analyzer
    ];
    userSettings = {
      "workbench.colorTheme" = "Solarized Dark";
    };
  };
}
