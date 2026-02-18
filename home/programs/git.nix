{...}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Bharath Krishnan";
        email = "bkrishnan@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
    extraConfig = {
      alias.lg = "log --color --graph --pretty=format:'%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)' --abbrev-commit --date=relative";
    };
  };
}
