{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };

        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        packages = with pkgs; [
          cargo

          cargo-tauri

          toolchain

          rust-analyzer-unwrapped

          nodejs_18

          pnpm
        ];

        nativeBuildPackages = with pkgs; [
          pkg-config

          dbus

          openssl

          glib

          gtk3

          libsoup

          webkitgtk

          librsvg
        ];

        libraries = with pkgs; [
          webkitgtk

          gtk3

          cairo

          gdk-pixbuf

          glib

          dbus

          openssl

          librsvg
        ];

      in {

        devShells.default = pkgs.mkShell {
          buildInputs = packages;

          nativeBuildInputs = nativeBuildPackages;

          shellHook = with pkgs; ''
            export LD_LIBRARY_PATH="${
              lib.makeLibraryPath libraries
            }:$LD_LIBRARY_PATH"

            export OPENSSL_INCLUDE_DIR="${openssl.dev}/include/openssl"

            export OPENSSL_LIB_DIR="${openssl.out}/lib"

            export OPENSSL_ROOT_DIR="${openssl.out}"

            export RUST_SRC_PATH="${toolchain}/lib/rustlib/src/rust/library"
          '';
        };
      });
}
