{ config, pkgs, ... }:

{
  programs.git.settings = {
    user.email = "s.hiraoku@gmail.com";
    ghq.root = "/Volumes/SSD/ghq";
  };

  home.sessionVariables.LAZYGIT_COMMIT_PROMPT = "Generate a single-line commit message in Conventional Commits format: type(scope): description. Type must be one of: feat, fix, docs, style, refactor, test, chore. Base the message strictly on the provided diff. Output ONLY the commit message, nothing else.";
}
