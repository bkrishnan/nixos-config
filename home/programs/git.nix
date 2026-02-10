{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Bharath Krishnan";
    userEmail = "bkrishnan@gmail.com";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };
}
