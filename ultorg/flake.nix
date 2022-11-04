{
  description = "A user interface for relational data";


  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.default = with import nixpkgs { system = "x86_64-linux"; };
      let
        archive = fetchurl {
          name = "ultorg.zip";
          url = https://ultorgbeta.s3.us-west-004.backblazeb2.com/u1.2.4/ultorg-1.2.4-linux_x64.zip?X-Amz-Security-Token=&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20221031T144117Z&X-Amz-SignedHeaders=host&X-Amz-Expires=604800&X-Amz-Credential=0043c2bcce118050000000002%2F20221031%2Fus-west-004%2Fs3%2Faws4_request&X-Amz-Signature=f280a109498fe437ac5c0b8113e3732b6df1ba86df372607480131379d2518c6;
          sha256 = "YWOVdfBd3a0alwxXmc83RIXrQKwUBIyVtPtoJIMix28=";
        };
        unzip = { name, archive }: pkgs.runCommand "${name}.zip" {
          buildInputs = [ patchelf pkgs.unzip ];
        } ''
          unzip ${archive}
          mkdir -p $out
          cp -R ultorg/* $out/

          patchelf \
            --set-rpath "${libPath}:$out/jre/17.34.19-ca-jdk17.0.3-linux_x64/lib/" \
            --set-interpreter ${glibc}/lib64/ld-linux-x86-64.so.2 \
            $out/jre/17.34.19-ca-jdk17.0.3-linux_x64/bin/java \
        '';
        contents = unzip { inherit archive; name = "ultorg"; };
        libPath = lib.makeLibraryPath [ zlib ];
        pkg = stdenv.mkDerivation rec {
          name = "ultorg";
          version = "1.2.4";
          src = contents;

          installPhase = ''
            mkdir -p $out
            cp -R ${src}/* $out/
          '';

          meta = with lib; {
            description = "A user interface for relational data";
            platforms = platforms.all;
          };
        };
      in
      buildFHSUserEnv {
        name = "ultorg";
        targetPkgs = pkgs: (with pkgs; [ freetype fontconfig jdk11 xorg.libX11 xorg.libXi xorg.libXext xorg.libXrender xorg.libXtst ] );
        runScript = "${pkg.outPath}/bin/ultorg";

        extraInstallCommands = ''
          cat <<EOF > ultorg.desktop
          [Desktop Entry]
          Type=Application
          Version=1.2.4
          Name=Ultorg
          Comment=A user interface for relational data
          Exec=$out/bin/ultorg
          Terminal=false
          EOF

          mkdir -p $out/share/applications
          cp ultorg.desktop $out/share/applications/
        '';
      };

  };
}
