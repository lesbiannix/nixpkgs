{
  lib,
  fetchFromGitHub,
  python3Packages,
  qt6,
}:

python3Packages.buildPythonPackage rec {
  pname = "vial-gui";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "vial-kb";
    repo = "vial-gui";
    tag = "v${version}";
    hash = "sha256-TWcm+UgROpd5pX/EV0SMx52C9i9Ip9vT61OQhsTiRi8=";
  };

  format = "other";

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  dependencies = with python3Packages; [
    fbs
    certifi
    pyqt5
    simpleeval
    hidapi
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec
    cp -r . $out/libexec/vial

    sed -i '1i#!/usr/bin/env python' $out/libexec/vial/src/main/python/main.py
    chmod u+x $out/libexec/vial/src/main/python/main.py
    ln -s $out/libexec/vial/src/main/python/main.py $out/bin/vial-gui

    mkdir -p $out/etc/udev/rules.d/ # https://get.vial.today/getting-started/linux-udev.html
    echo 'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"' > $out/etc/udev/rules.d/92-viia.rules

    runHook postInstall
  '';

  makeWrapperArgs = [ "--chdir $out/libexec/vial" ];

  postFixup = ''
    wrapPythonProgramsIn "$out/libexec/vial/src/main/python" "$out $pythonPath"
  '';

  meta = {
    description = "Open-source GUI and QMK fork for configuring your keyboard in real time";
    homepage = "https://get.vial.today";
    license = lib.licenses.gpl2Plus;
    mainProgram = "vial-gui";
    maintainers = with lib.maintainers; [ kranzes ];
    platforms = lib.platforms.linux;
  };
}
