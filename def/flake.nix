{
  description = "default template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };

      R-env = pkgs.rWrapper.override {
        packages = with pkgs.rPackages; [
          tidyverse 
          tidymodels
          glmnet
          class
          caret
          patchwork
          cowplot
          scales
        ];
      };

      radian = pkgs.python3.pkgs.buildPythonPackage rec {
          pname = "radian";
          version = "0.6.4";
          src = fetchPypi {
            inherit pname version;
            sha256 = "4524a10335a6464a423a58ab85544fb37ebb9973cd647b00cc4eb40637bdf40c";
          };
          doCheck = false;
          propagatedBuildInputs = with pkgs.python3Packages;  [
            numpy
          ];
        };
      
      dontTestPackage = drv: drv.overridePythonAttrs (old: { doCheck = false; });
      python-env = pkgs.python3.withPackages (ps: with ps; [ 
        pip
        tqdm
        numpy
        pandas
        scipy
        scikit-learn
        statsmodels
        matplotlib
        (dontTestPackage seaborn) # tests fail on darwin due to different numerical results on intel vs ARM
        radian
      ]);

    
    in rec {
      devShells.default = with pkgs; mkShell {
        name = "shellEnv";
        buildInputs = [
          R-env python-env
        ];

        shellHook = ''
          mkdir -p "$(pwd)/_libs"
          export R_LIBS_USER="$(pwd)/_libs"
          export PYTHONPATH="${python-env}/bin/python"
          alias rs="${R-env}/bin/Rscript"
          alias R="${R-env}/bin/R"
          alias r="radian"
          alias py="${python-env}/bin/python"
        '';
      };
    });
}
