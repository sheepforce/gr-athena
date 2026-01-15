{
  description = "gr-athena";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      ovl = final: prev: {
        gr-athena = final.callPackage ./nix/default.nix {
          hdf5 =
            (final.hdf5.override {
              cppSupport = false;
              mpiSupport = true;
              threadsafe = true;
            }).overrideAttrs
              (old: {
                cmakeFlags = old.cmakeFlags ++ [
                  "-DALLOW_UNSUPPORTED=ON"
                  "-DHDF5_BUILD_HL_LIB=ON"
                ];
              });
        };
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ovl ];
        };

      in
      {
        packages.default = pkgs.gr-athena;

        formatter = pkgs.nixfmt-tree;
      }
    )
    // {
      overlays.default = ovl;
    };

}
