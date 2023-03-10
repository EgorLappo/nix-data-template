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

      py = pkgs.python3;
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
          alias py="${python-env}/bin/python"
        '';
      };
    });
}
