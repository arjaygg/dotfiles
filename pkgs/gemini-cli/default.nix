{ lib, buildNpmPackage, fetchurl }:

buildNpmPackage rec {
  pname = "gemini-cli";
  version = "0.1.7";

  src = fetchurl {
    url = "https://github.com/google-gemini/gemini-cli/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-UsQ/Ow3iB3d1sgn8j6CzaTetofiPZb2InNuNGoDUGXU=";
  };

  npmDepsHash = "sha256-otogkSsKJ5j1BY00y4SRhL9pm7CK9nmzVisvGCDIMlU=";

  buildPhase = ''
    runHook preBuild
    npm run bundle
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bundle/gemini.js $out/bin/gemini
    chmod +x $out/bin/gemini
    runHook postInstall
  '';

  meta = with lib; {
    description = "Google Gemini CLI";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = licenses.asl20;
    mainProgram = "gemini";
  };
}
