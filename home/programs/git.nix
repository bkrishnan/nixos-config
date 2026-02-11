{ ... }:

{
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
  };
}
