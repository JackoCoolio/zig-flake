{
  description = "Zig compiler development.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-for-zls.url = "github:mitchell/zig-overlay/efc4c87cce0e2dcdf52435147d1d8d514ab47bf2";
    zls = {
      url = "github:zigtools/zls";
      inputs.zig-overlay.follows = "zig-for-zls";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        devShells.default = pkgs.mkShell {
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc ];

          shellHook = ''
            # add compiled zig to path
            export PATH="$PWD/master/build/stage3/bin:$PATH"
          '';

          nativeBuildInputs = with pkgs;
            [
              cmake
              gdb
              libxml2
              ninja
              qemu
              wasmtime
              zlib
              just
            ]
            ++ (with llvmPackages_20; [
              clang
              clang-unwrapped
              lld
              llvm
              lldb
            ])
            ++ [
              inputs.zls.packages.${system}.default
            ];

          hardeningDisable = ["all"];
        };
      }
    );
}
