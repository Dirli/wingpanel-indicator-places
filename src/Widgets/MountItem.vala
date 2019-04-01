/*
 * Copyright (c) 2018 Dirli <litandrej85@gmail.com>
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

namespace Places.Widgets {
    public class MountItem : ListItem {
        private GLib.Mount mount;
        public signal void unmount_end ();
        public MountItem (GLib.Mount mount, string? mount_class) {
            string elem_image, _category_name;
            switch (mount_class) {
                case "device":
                    elem_image = "drive-harddisk";
                    _category_name = _("Devices");
                    break;
                case "network":
                    elem_image = "folder-remote";
                    _category_name = _("Network");
                    break;
                default:
                    elem_image = "folder";
                    _category_name = _("Other");
                    break;
            }

            base (mount.get_name (), elem_image, mount.get_symbolic_icon ());
            category_name = _category_name;
            this.mount = mount;
            Gtk.Button unmount_button = new Gtk.Button.from_icon_name ("media-eject-symbolic", Gtk.IconSize.MENU);
            unmount_button.set_relief (Gtk.ReliefStyle.NONE);
            unmount_button.set_can_focus (false);
            unmount_button.set_halign (Gtk.Align.END);

            unmount_button.clicked.connect (()=> {
                if (mount.can_eject ()) {
                    do_eject ();
                } else {
                    do_unmount ();
                }
            });

            if (mount.can_eject ()) {
                unmount_button.set_tooltip_text (_("Eject"));
            } else {
                unmount_button.set_tooltip_text (_("Unmount"));
            }

            overlay.add_overlay (unmount_button);
        }
        /*
         * Ejects a mount
         */
        private void do_eject () {
            mount.eject_with_operation.begin (GLib.MountUnmountFlags.NONE, null, null, on_eject);
        }

        private void on_eject (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                mount.eject_with_operation.end (res);
                unmount_end ();
            } catch (GLib.Error e) {
                warning (_("Error while ejecting device"));
                warning (e.message);
            }
        }
        /*
         * Unmounts a mount
         */
        private void do_unmount () {
            mount.unmount_with_operation.begin (GLib.MountUnmountFlags.NONE, null, null, on_unmount);
        }

        private void on_unmount (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                mount.unmount_with_operation.end (res);
                unmount_end ();
            } catch (GLib.Error e) {
                warning (_("Error while unmounting volume"));
                warning (e.message);
            }
        }
    }
}
