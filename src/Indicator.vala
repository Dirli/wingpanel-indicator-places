/*
 * Copyright (c) 2018-2020 Dirli <litandrej85@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

namespace Places {
    public class Indicator : Wingpanel.Indicator {
        private GLib.VolumeMonitor volume_monitor;

        private Widgets.Popover? main_widget = null;
        private Gtk.Box? panel_label = null;

        public Indicator () {
            Object (code_name : "places-indicator");

            Gtk.IconTheme.get_default ().add_resource_path ("/io/elementary/desktop/wingpanel/places");

            volume_monitor = GLib.VolumeMonitor.get ();

            visible = true;
        }

        public override Gtk.Widget get_display_widget () {
            if (panel_label == null) {
                panel_label = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);

                Gtk.Image places_icon = new Gtk.Image.from_icon_name ("places-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
                panel_label.pack_start (places_icon);
            }

            return panel_label;
        }

        public override Gtk.Widget? get_widget () {
            if (main_widget == null) {
                main_widget = new Widgets.Popover ();
                main_widget.close_poover.connect (() => {
                    close ();
                });
            }

            return main_widget;
        }

        private void refresh_mounts () {
            if (main_widget == null) {
                return;
            }

            main_widget.clear_volumes ();

            foreach (GLib.Drive drive in volume_monitor.get_connected_drives ()) {
                foreach (GLib.Volume volume in drive.get_volumes ()) {
                    GLib.Mount mount = volume.get_mount ();

                    if (mount == null) {
                        main_widget.add_volume (volume);
                    } else {
                        main_widget.add_mount (mount, volume.get_identifier ("class"));
                    }
                }
            }
            // Add volumes not connected with a drive
            foreach (GLib.Volume volume in volume_monitor.get_volumes ()) {
                if (volume.get_drive () != null) {
                    continue;
                }

                GLib.Mount mount = volume.get_mount ();
                if (mount == null) {
                    main_widget.add_volume (volume);
                } else {
                    main_widget.add_mount (mount, volume.get_identifier ("class"));
                }
            }
            // Add mounts without volumes
            foreach (GLib.Mount mount in volume_monitor.get_mounts ()) {
                if (mount.is_shadowed () || mount.get_volume () != null) {
                    continue;
                }

                GLib.File root = mount.get_default_location ();
                if (!root.is_native ()) {
                    main_widget.add_mount (mount, "network");
                } else {
                    main_widget.add_mount (mount, "device");
                }
            }

            main_widget.get_child_at (0, 1).show_all ();
        }

        private void on_mount_changed (GLib.Mount mount) {
            refresh_mounts ();
        }

        private void on_volume_changed (GLib.Volume volume) {
            refresh_mounts ();
        }

        public override void opened () {
            refresh_mounts ();

            volume_monitor.volume_added.connect (on_volume_changed);
            volume_monitor.volume_removed.connect (on_volume_changed);
            volume_monitor.mount_added.connect (on_mount_changed);
            volume_monitor.mount_removed.connect (on_mount_changed);
        }

        public override void closed () {
            volume_monitor.volume_added.disconnect (on_volume_changed);
            volume_monitor.volume_removed.disconnect (on_volume_changed);
            volume_monitor.mount_added.disconnect (on_mount_changed);
            volume_monitor.mount_removed.disconnect (on_mount_changed);
        }
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Places Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new Places.Indicator ();
    return indicator;
}
