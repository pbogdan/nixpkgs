{ stdenv
, fetchurl
, libhandy
}:
libhandy.overrideAttrs (old: rec {
  version = "0.90.0";

  src = fetchurl {
    url = "mirror://gnome/sources/libhandy/${stdenv.lib.versions.majorMinor version}/${old.pname}-${version}.tar.xz";
    sha256 = "11arvwwn0np144fihcvb87ga92y32i69vj0fla72k0x47ad8dc3a";
  };

  patches = [ ];

  # (/build/libhandy-0.90.0/build/tests/test-avatar:2202): Gtk-WARNING **: 18:11:57.078: Found an
  # icon but could not load it. Most likely gdk-pixbuf does not provide SVG support.
  doCheck = false;
})
