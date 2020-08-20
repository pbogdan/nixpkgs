{ stdenv
, rustPlatform
, gettext
, meson
, ninja
, fetchFromGitLab
, pkg-config
, gtk3
, glib
, gdk-pixbuf
, librsvg
, desktop-file-utils
, appstream-glib
, wrapGAppsHook
, python3
, gnome3
, config
}:

rustPlatform.buildRustPackage rec {
  pname = "gnome-tour";
  version = "3.37.1";

  # We don't use the uploaded tar.xz because it comes pre-vendored
  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "gnome-tour";
    rev = version;
    sha256 = "1ki3b99gz0mg4lxkdp8aqsiqj92izz22fbavbm2in4izi07mjv6n";
  };

  cargoSha256 = "0vlxwyr102b8s1bszsiw7pym591g7l8xwrqgidvyq6fpqq5j2xqm";

  mesonFlags = [
    "-Ddistro_name=NixOS"
    "-Ddistro_icon_name=nix-snowflake"
    "-Ddistro_version=20.09"
  ];

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gettext
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook
  ];

  buildInputs = [
    gdk-pixbuf
    librsvg
    glib
    gtk3
  ];

  # Don't use buildRustPackage phases, only use it for rust deps setup
  configurePhase = null;
  buildPhase = null;
  checkPhase = null;
  installPhase = null;

  postPatch = ''
    chmod +x build-aux/meson_post_install.py
    patchShebangs build-aux/meson_post_install.py
  '';

  # passthru = {
  #   updateScript = gnome3.updateScript {
  #     packageName = pname;
  #   };
  # };

  meta = with stdenv.lib; {
    homepage = "https://gitlab.gnome.org/GNOME/gnome-tour";
    description = "GNOME Greeter & Tour";
    maintainers = teams.gnome.members;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
