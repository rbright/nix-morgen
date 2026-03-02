{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  electron,
  asar,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libnotify,
  libsecret,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxshmfence,
  libxkbcommon,
  libxcb,
  nspr,
  nss,
  pango,
}:
stdenv.mkDerivation rec {
  pname = "morgen";
  version = "4.0.1";
  buildId = "260126rpo7mcydr";

  src = fetchurl {
    name = "morgen-${version}-${buildId}.deb";
    url = "https://dl.todesktop.com/210203cqcj00tw1/builds/${buildId}/linux/deb/x64";
    hash = "sha256-UmbHA7p3nuat0zv/uIHZV9li/LHOnk9oUB1RGJwj6zE=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    asar
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libnotify
    libsecret
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxshmfence
    libxkbcommon
    libxcb
    nspr
    nss
    pango
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    dpkg-deb -x "$src" .
    mv usr "$out"
    mv opt "$out"

    workdir="$TMPDIR/work"
    mkdir -p "$workdir"

    asar extract "$out/opt/Morgen/resources/app.asar" "$workdir"

    substituteInPlace "$workdir/dist/main.js" \
      --replace-fail "process.resourcesPath,\"todesktop-runtime-config.json" "\"$out/opt/Morgen/resources/todesktop-runtime-config.json"

    if grep -Fq 'Exec=\".concat(process.execPath,' "$workdir/dist/main.js"; then
      substituteInPlace "$workdir/dist/main.js" \
        --replace-fail "Exec=\".concat(process.execPath," "Exec=\".concat(\"$out/bin/morgen\","
    fi

    asar pack --unpack='{*.node,*.ftz,rect-overlay}' "$workdir" "$out/opt/Morgen/resources/app.asar"

    substituteInPlace "$out/share/applications/morgen.desktop" \
      --replace-fail '/opt/Morgen' "$out/bin"

    makeWrapper ${electron}/bin/electron "$out/bin/morgen" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer --enable-wayland-ime=true}} $out/opt/Morgen/resources/app.asar"

    runHook postInstall
  '';

  meta = {
    description = "All-in-one Calendars, Tasks and Scheduler";
    homepage = "https://morgen.so/";
    mainProgram = "morgen";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
