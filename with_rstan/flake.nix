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
          brms
          rstanarm
        ];
      };

      py = pkgs.python3;

      rchitect = py.pkgs.buildPythonPackage rec {
          pname = "rchitect";
          version = "0.3.40";
          src = py.pkgs.fetchPypi {
            inherit pname version;
            sha256 = "1c5de5c4914dcb34225e7b62dbfc5df7b857b0b4bc18d4adf03611c45847b8b7";
          };
          doCheck = false;
          propagatedBuildInputs = with pkgs.python3Packages;  [
            six cffi
          ];
        };

      radian = py.pkgs.buildPythonPackage rec {
          pname = "radian";
          version = "0.6.4";
          src = py.pkgs.fetchPypi {
            inherit pname version;
            sha256 = "4524a10335a6464a423a58ab85544fb37ebb9973cd647b00cc4eb40637bdf40c";
          };
          doCheck = false;
          propagatedBuildInputs = with pkgs.python3Packages;  [
            numpy pygments prompt_toolkit rchitect
          ];
        };
      
      dontTestPackage = drv: drv.overridePythonAttrs (old: { doCheck = false; });
      python-env = py.withPackages (ps: with ps; [ 
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
          alias r="radian --r-binary=${R-env}/bin/R"
          alias py="${python-env}/bin/python"
        '';
      };
    });
}
