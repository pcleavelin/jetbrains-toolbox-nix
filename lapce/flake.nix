{
  description = "The Lapce Rust Code Editor";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = with import nixpkgs { system = "x86_64-linux"; };
    let
      desktopItem = makeDesktopItem {
        name = "lapce";
        desktopName = "Lapce";
        exec = "lapce";
      };
      archive = fetchzip {
        url = https://github.com/lapce/lapce/releases/download/v0.2.3/Lapce-linux.tar.gz;
        sha256 = "zd8SQUr1o6nQkGj2LzaDv1Xk7A2G7LxKh0vPr2mHNGY=";
      };
    in
    stdenv.mkDerivation rec {
      name = "lapce";
      version = "0.2.3";
      src = archive;

      nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib zlib gtk3 ];

      installPhase = ''
        mkdir -p $out/bin

        cp ${src}/* $out/bin/
        cp -R ${desktopItem}/share $out
      '';

      meta = with lib; {
        description = "Lighting-fast and Powerful Code Editor";
        platforms = platforms.all;
      };
    };

  };
}
