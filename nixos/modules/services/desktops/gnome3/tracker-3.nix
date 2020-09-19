# Tracker daemon.

{ config, pkgs, lib, ... }:

with lib;

{

  meta = {
    maintainers = teams.gnome.members;
  };

  ###### interface

  options = {

    services.gnome3.tracker-3 = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Tracker services, a search engine,
          search tool and metadata storage system.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf config.services.gnome3.tracker-3.enable {

    environment.systemPackages = [ pkgs.tracker-3 ];

    services.dbus.packages = [ pkgs.tracker-3 ];

    systemd.packages = [ pkgs.tracker-3 ];

  };

}
