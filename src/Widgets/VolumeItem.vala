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
    public class VolumeItem : ListItem {
        public signal void mount_done (GLib.File open_file);

        private GLib.Volume volume;

        public VolumeItem (GLib.Volume volume) {
            string elem_image, _category_name;
            switch (volume.get_identifier("class")) {
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

            base (volume.get_name (), elem_image, volume.get_symbolic_icon());

            category_name = _category_name;
            this.volume = volume;

            iter_button.clicked.connect (on_button_clicked);
        }

        private void on_button_clicked () {
            volume.mount.begin(GLib.MountMountFlags.NONE, null, null, on_mount);
        }

        private void on_mount (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                volume.mount.end(res);
                mount_done (volume.get_mount().get_root());
            } catch (GLib.Error e) {
                warning (_("Error while mounting volume"));
                warning (e.message);
            }
        }
    }
}
