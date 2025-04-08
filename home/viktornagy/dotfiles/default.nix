{inputs, ...}:

{
  imports = [

  ];

  home.file.".config/nvim" = {
    source = "${inputs.dotfiles}/.config/nvim";
    recursive = true;
  };
}
