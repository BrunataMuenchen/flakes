{
  lib,
  clang,
  gnumake,
  openssl
}:

clang.stdenv.mkDerivation rec {
  pname = "template";
  version = "0.1.0";

  src = ./src;

  buildInputs = [ gnumake openssl ];

  meta = with lib; {
    description = ''
      A sample project
    '';
  };
}