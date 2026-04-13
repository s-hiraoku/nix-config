{ config, pkgs, ... }:

{
  programs.lazygit = {
    enable = true;
    settings = {
      git.pagers = [
        {
          colorArg = "always";
          pager = "delta --dark --paging=never --side-by-side --line-numbers";
        }
      ];
      customCommands = [
        {
          key = "<c-g>";
          description = "AI Commit (Claude Code)";
          context = "files";
          output = "terminal";
          command = ''bash -c '
            diff=$(git diff --cached)
            if [ -z "$diff" ]; then
              echo "Error: No staged changes found."
              read -n 1 -s -r -p "Press any key to continue..."
              exit 1
            fi
            echo "Generating commit message with Claude..."
            msg=$(echo "$diff" | claude -p --model haiku \
              "Generate a single-line commit message in Conventional Commits format: type(scope): description. Type must be one of: feat, fix, docs, style, refactor, test, chore. Base the message strictly on the provided diff. Output ONLY the commit message, nothing else." 2>&1)
            if [ $? -ne 0 ] || [ -z "$msg" ]; then
              echo "Error: Failed to generate commit message."
              echo "$msg"
              read -n 1 -s -r -p "Press any key to continue..."
              exit 1
            fi
            git commit -e -m "$msg"
          ' '';
          loadingText = "Generating commit message with Claude...";
        }
      ];
    };
  };
}
