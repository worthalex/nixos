{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;

    extraPackages = with pkgs;
      [
        # Neovim dependencies
        gnumake
        fd
        fswatch
        libcxxStdenv
        ripgrep
        tree-sitter
        unzip
        wget

        # Mason language providers
        go
        php83Packages.composer
        php
        luajitPackages.luarocks-nix
        julia
        python311Packages.pip

        # Neovim providers
        nodePackages_latest.neovim

        # LuaSnip
        luajitPackages.jsregexp
      ]
      ++ [
        # CSS/HTML/ESLINT/MD/JSON
        vscode-langservers-extracted

        # C/C++
        clang-tools
        codelldb
        cppcheck

        # Java
        jdt-language-server

        # JavaScript / TypeScript
        prettierd
        nodePackages.prettier
        nodePackages.typescript-language-server

        # JSON
        jq

        # Just
        just

        # Lua
        lua-language-server
        stylua

        # Markdown
        markdownlint-cli
        marksman

        # Nix
        deadnix
        nil
        statix

        # Rust
        rust-analyzer-nightly

        # sh
        shellcheck
        shfmt

        # TOML
        taplo

        # YAML
        yaml-language-server
        yq
      ];

    viAlias = true;
    vimAlias = true;

    withNodeJs = true;
  };

  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };
}
