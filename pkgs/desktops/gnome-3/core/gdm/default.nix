{ stdenv
, dconf
, fetchurl
, itstool
, libtool
, libxml2
, meson
, ninja
, pkg-config
, substituteAll

, accountsservice
, coreutils
, glib
, gnome3
, gobject-introspection
, gtk3
, libX11
, libcanberra-gtk3
, librsvg
, nixos-icons
, pam
, plymouth
, systemd
, xlibs
, xorg
, xwayland
}:
let
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/4f041870efa1a6f0799ef4b32bb7be2cafee7a74/logo/nixos.svg";
    sha256 = "0b0dj408c1wxmzy6k0pjwc4bzwq286f1334s3cqqwdwjshxskshk";
  };

  override = substituteAll {
    src = ./org.gnome.login-screen.gschema.override;
    inherit icon;
  };
in
stdenv.mkDerivation rec {
  pname = "gdm";
  version = "3.38.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gdm/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "1fimhklb204rflz8k345756jikgbw8113hms3zlcwk6975f43m26";
  };

  patches = [
    # Change hardcoded paths to nix store paths.
    (substituteAll {
      src = ./fix-paths.patch;
      inherit coreutils plymouth xwayland;
    })

    # The following patches implement certain environment variables in GDM which are set by
    # the gdm configuration module (nixos/modules/services/x11/display-managers/gdm.nix).

    ./gdm-x-session_extra_args.patch

    # Allow specifying a wrapper for running the session command.
    ./gdm-x-session_session-wrapper.patch

    # Forwards certain environment variables to the gdm-x-session child process
    # to ensure that the above two patches actually work.
    ./gdm-session-worker_forward-vars.patch

    # Set up the environment properly when launching sessions
    # https://github.com/NixOS/nixpkgs/issues/48255
    ./reset-environment.patch
  ];

  nativeBuildInputs = [
    dconf
    itstool
    libtool
    libxml2
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    accountsservice
    glib
    gobject-introspection
    gtk3
    libX11
    libcanberra-gtk3
    librsvg
    pam
    plymouth
    systemd
    xlibs.libXdmcp
  ];

  initialVT = "7";

  preConfigure = ''
    substituteInPlace build-aux/find-x-server.sh \
      --replace "/usr/bin/X" "${xorg.xorgserver.out}/bin/X"
    # fix up a typo in data/meson.build
    substituteInPlace data/meson.build \
      --replace "XSession.in" "Xsession.in"
  '';

  mesonFlags = [
    "-Dsysconfdir=${placeholder "out"}/etc"
    "-Dlocalstatedir=/var"
    "-Dplymouth=enabled"
    "-Dgdm-xsession=true"
    "-Dinitial-vt=${initialVT}"
    "-Dsystemdsystemunitdir=${placeholder "out"}/etc/systemd/system"
    "-Dsystemduserunitdir=${placeholder "out"}/lib/systemd/user"
    "-Dudev-dir=${placeholder "out"}/lib/udev"
    "-Dselinux=disabled"
    "-Dlibaudit=disabled"
  ];

  enableParallelBuilding = true;

  # @HACK: we want GDM to read its configuration from /etc but at the same time prevent it from
  # writing there during the install phase. With autotools we could set sysconfdir to /etc and then
  # override it just during the install phase. I couldn't figure out how to do it with meson/ninja
  # so did it other way around: sysconfdir point to $out/etc and we manually adjust the constants in
  # the generated config.h.
  preBuild = ''
    substituteInPlace config.h \
      --replace "${placeholder "out"}/etc" "/etc"
  '';

  # @TODO: why is this suddenly necessary?
  postInstall = ''
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  postFixup = ''
    schema_dir=${glib.makeSchemaPath "$out" "${pname}-${version}"}
    install -D ${override} $schema_dir/org.gnome.login-screen.gschema.override
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = "gdm";
      attrPath = "gnome3.gdm";
    };
  };

  meta = with stdenv.lib; {
    description = "A program that manages graphical display servers and handles graphical user logins";
    homepage = "https://wiki.gnome.org/Projects/GDM";
    license = licenses.gpl2Plus;
    maintainers = teams.gnome.members;
    platforms = platforms.linux;
  };
}
