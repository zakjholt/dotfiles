{ pkgs ? import <nixpkgs> {}
}:

pkgs.mkShell {
  buildInputs = [
    pkgs.nodejs
    pkgs.python3
    pkgs.yarn
    pkgs.docker
    pkgs.docker-compose
  ];
}
