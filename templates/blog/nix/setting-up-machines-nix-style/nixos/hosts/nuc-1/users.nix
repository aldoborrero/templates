{pkgs, ...}: {
  users.users.nuc = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    password = "nuc";
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHXBP3u/XWr7fwix5lVixsAlfBNGK06aCVVQ9sRJOBCZAAAAGnNzaDphbGRvYm9ycmVyb0BnaXRodWIuY29t ssh:aldoborrero@github.com"
    ];
  };
}
