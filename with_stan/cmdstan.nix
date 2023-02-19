### ADAPTED FROM https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/development/compilers/cmdstan/default.nix

{ lib, stdenv, fetchurl, python3, runtimeShell }:

stdenv.mkDerivation rec {
  pname = "cmdstan";
  version = "2.31.0";

  # includes stanc binaries needed to build cmdstand
  src = fetchurl {
    url = "https://github.com/stan-dev/cmdstan/archive/refs/tags/v${version}.tar.gz";
    sha256 = "eba7f0cb93a57a39c65135b3a27c64bda0921ab300d236a6248a95ef098a06b5";
  };

  buildFlags = [ "build" ];
  enableParallelBuilding = true;

  doCheck = true;
  checkInputs = [ python3 ];

  CXXFLAGS = lib.optionalString stdenv.isDarwin "-D_BOOST_LGAMMA";

  postPatch = ''
    substituteInPlace stan/lib/stan_math/make/libraries \
      --replace "/usr/bin/env bash" "bash"
    patchShebangs .
  '';

  checkPhase = ''
    ./runCmdStanTests.py -j$NIX_BUILD_CORES src/test/interface
  '';

  installPhase = ''
    mkdir -p $out/opt $out/bin
    cp -r . $out/opt/cmdstan
    ln -s $out/opt/cmdstan/bin/stanc $out/bin/stanc
    ln -s $out/opt/cmdstan/bin/stansummary $out/bin/stansummary
    cat > $out/bin/stan <<EOF
    #!${runtimeShell}
    make -C $out/opt/cmdstan "\$(realpath "\$1")"
    EOF
    chmod a+x $out/bin/stan
  '';

  # Hack to ensure that patchelf --shrink-rpath get rids of a $TMPDIR reference.
  preFixup = "rm -rf $(pwd)";

  meta = {
    broken = stdenv.isLinux && stdenv.isAarch64;
    description = "Command-line interface to Stan";
    longDescription = ''
      Stan is a probabilistic programming language implementing full Bayesian
      statistical inference with MCMC sampling (NUTS, HMC), approximate Bayesian
      inference with Variational inference (ADVI) and penalized maximum
      likelihood estimation with Optimization (L-BFGS).
    '';
    homepage = "https://mc-stan.org/interfaces/cmdstan.html";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}