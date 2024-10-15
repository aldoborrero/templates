{
  buildGoApplication,
  lib,
}:
buildGoApplication rec {
  pname = "go-project";
  version = "0.1.0";

  src = lib.cleanSource ./.;

  modules = ./gomod2nix.toml;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/aldoborrero/${pname}/internal/build.Version=v${version}"
  ];

  subPackages = ["cmd/project/main.go"];

  meta = {
    mainProgram = "go-project";
  };
}
