{ stdenv
, fetchurl
, libhandy
}:
libhandy.overrideAttrs (old: rec {
  version = "1.0.0";

  src = fetchurl {
    url = "mirror://gnome/sources/libhandy/${stdenv.lib.versions.majorMinor version}/${old.pname}-${version}.tar.xz";
    sha256 = "16b6s8c8akvjlgp5gpcz4jpmmwzyd30c1snn0n974zbvyj18afd9";
 };

  patches = [ ];

  # (/build/libhandy-0.90.0/build/tests/test-avatar:2202): Gtk-WARNING **: 18:11:57.078: Found an
  # icon but could not load it. Most likely gdk-pixbuf does not provide SVG support.
  doCheck = false;
})
