{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          github.copilot
          github.copilot-chat
          ms-vscode.cpptools
          ms-python.python
          golang.go
          rust-lang.rust-analyzer
          eamodio.gitlens
          jnoortheen.nix-ide
        ];
        userSettings = {
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
          "editor.formatOnSave" = true;
          "workbench.colorTheme" = "Solarized Light";
          "github.copilot.nextEditSuggestions.enabled" = true;
          "gitlens.ai.modal" = "vscode";
          "git.confirmSync" = false;
          "nix.formatterPath" = "alejandra";
          "json.schemaDownload.trustedDomains" = {
            "https://schemastore.azurewebsites.net/" = true;
            "https://raw.githubusercontent.com/microsoft/vscode/" = true;
            "https://raw.githubusercontent.com/devcontainers/spec/" = true;
            "https://www.schemastore.org/" = true;
            "https://json.schemastore.org/" = true;
            "https://json-schema.org/" = true;
            "https://developer.microsoft.com/json-schemas/" = true;
            "https://biomejs.dev" = true;
          };
          "chat.tools.terminal.autoApprove" = {
            "journalctl" = true;
          };
        };
      };
    };
  };
}
