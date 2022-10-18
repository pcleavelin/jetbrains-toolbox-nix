{
  description = "Manage your IDEs the easy way";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = with import nixpkgs { system = "x86_64-linux"; };
        let
            name = "jetbrains-toolbox";
            src = fetchzip {
                url = https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.26.2.13244.tar.gz;
                sha256 = "sDDTB0gJqWpDEGrAOUu0iNMN6rV4eHwxliXPW2m5TJw=";
            };

            libPath = lib.makeLibraryPath [ stdenv.cc.cc.lib glibc xorg.xcbutilkeysyms gcc ];
            extractApp = { name, src }: pkgs.runCommand "${name}-extracted" {
                buildInputs = [ appimageTools.appimage-exec patchelf gcc libcef ];
            } ''
                appimage-exec.sh -x $out ${src}/jetbrains-toolbox*
                patchelf \
                    --set-rpath "${libPath}:$out/jre/lib:/usr/lib64" \
                    --set-interpreter ${glibc}/lib64/ld-linux-x86-64.so.2 \
                    $out/jetbrains-toolbox 
                patchelf --set-interpreter ${glibc}/lib64/ld-linux-x86-64.so.2 $out/glibcversion
            '';
            appimageContents = extractApp { inherit name src; };
        in
        appimageTools.wrapAppImage {
            inherit name;

            src = appimageContents;

            extraPkgs = pkgs: with pkgs; [ pkgs.libsecret stdenv.cc.cc.lib glibc ];
            extraInstallCommands = ''
                mkdir -p $out/share/applications
                install -m 444 -D ${appimageContents}/jetbrains-toolbox.desktop -t $out/share/applications
                    substituteInPlace $out/share/applications/jetbrains-toolbox.desktop \
                    --replace 'Exec=AppRun' 'Exec=${name} --updated-failed'
            '';
        };
  };
}
