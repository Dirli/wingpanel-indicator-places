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
    public class Popover : Gtk.Grid {
        private GLib.VolumeMonitor volume_monitor;

        private string user_home;
        private Gtk.ListBox user_listbox;
        private Gtk.ListBox std_listbox;
        private Gtk.ListBox vol_listbox;

        public signal void close_poover ();

        public Popover () {
            hexpand = true;
            margin_top = 15;
            user_home = GLib.Environment.get_home_dir ();

            volume_monitor = GLib.VolumeMonitor.get();

            user_listbox = new Gtk.ListBox();
            user_listbox.set_selection_mode (Gtk.SelectionMode.NONE);
            user_listbox.set_header_func(list_header_func);

            std_listbox = new Gtk.ListBox();
            std_listbox.set_selection_mode (Gtk.SelectionMode.NONE);

            vol_listbox = new Gtk.ListBox();
            vol_listbox.set_selection_mode (Gtk.SelectionMode.NONE);
            vol_listbox.set_header_func(list_header_func);

            Gtk.Separator v_separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            v_separator.margin_start = v_separator.margin_end = 3;

            add_std_places ();
            add_user_places ();
            attach (std_listbox,  0, 0, 1, 1);
            attach (vol_listbox,  0, 1, 1, 1);
            attach (v_separator,  1, 0, 1, 2);
            attach (user_listbox, 2, 0, 1, 2);
            show_all ();
        }

        public void add_std_places () {
            ListItem iter = new ListItem (_("Home Folder"), "user-home");
            iter.iter_button.clicked.connect (() => {open_directory (file_from_path ("file:" + user_home));});
            std_listbox.add (iter);

            iter = new ListItem (_("Root"), "computer");
            iter.iter_button.clicked.connect (() => {open_directory (file_from_path ("file:///"));});
            std_listbox.add (iter);

            // iter = new ListItem (_("Recent"), "document-open-recent");
            // iter.iter_button.clicked.connect (() => {open_directory (file_from_path ("recent:///"));});
            // std_listbox.add (iter);

            iter = new ListItem (_("Network"), "network-workgroup");
            iter.iter_button.clicked.connect (() => {open_directory (file_from_path ("network:///"));});
            std_listbox.add (iter);

            // iter = new ListItem (_("Trash"), "user-trash");
            // iter.iter_button.clicked.connect (() => {open_directory (file_from_path ("trash:///"));});
            // std_listbox.add (iter);
        }

        private void add_user_places () {
            string bookmarks_filename = GLib.Path.build_filename (user_home, ".config", "gtk-3.0", "bookmarks", null);
            GLib.File bookmarks_file = GLib.File.new_for_path (bookmarks_filename);

            if (!bookmarks_file.query_exists ()) {
                return;
            }

            try {
                var dis = new DataInputStream (bookmarks_file.read ());
                string line;

                while ((line = dis.read_line (null)) != null) {
                    string path = line.split (" ")[0];
                    var file = File.new_for_uri (path);
                    string label = file.get_basename ();

                    if (label == "/") {
                        label = line.split (" ")[1];
                    }

                    BookmarksItem iter = new BookmarksItem (label, get_user_icon (path));
                    iter.iter_button.clicked.connect (() => {open_directory (file_from_path (path));});
                    user_listbox.add (iter);
                }
            } catch (GLib.Error error) {
                warning (error.message);
            }
        }

        private GLib.File? file_from_path (string path) {
            string place = path.split(" ")[0];
            string unescaped_path = GLib.Uri.unescape_string(place);
            GLib.File file = GLib.File.new_for_uri(unescaped_path);
            return file;
        }

        private void open_directory (GLib.File? file) {
            if (file == null) {
                return;
            }

            close_poover ();

            GLib.AppLaunchContext launch_context = Gdk.Display.get_default().get_app_launch_context();
            GLib.List<GLib.File> file_list = new GLib.List<GLib.File>();
            file_list.append (file);

            try {
                GLib.AppInfo.get_default_for_type ("inode/directory", true).launch (file_list, launch_context);
            } catch (GLib.Error e) {
                warning (e.message);
            }
        }

        private string get_user_icon (string path) {
            if (path[0:3] == "smb" || path[0:3] == "ssh" || path[0:3] == "ftp" || path[0:3] == "net" || path[0:3] == "dav") {
                return "folder-remote";
            }

            string unescaped_path = GLib.Uri.unescape_string(path);
            string _path = unescaped_path.substring(7);

            if (_path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.DESKTOP)) {
                return "user-desktop";
            } else if (_path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.DOCUMENTS)) {
                return "folder-documents";
            } else if (_path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.DOWNLOAD)) {
                return "folder-download";
            } else if (_path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.MUSIC)) {
                return "folder-music";
            } else if (_path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.PICTURES)) {
                return "folder-pictures";
            } else if (_path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.PUBLIC_SHARE)) {
                return "folder-publicshare";
            } else if (_path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.TEMPLATES)) {
                return "folder-templates";
            } else if (_path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.VIDEOS)) {
                return "folder-videos";
            } else {
                return "folder";
            }
        }

        private void list_header_func (Gtk.ListBoxRow? before, Gtk.ListBoxRow? after) {
            ListItem? child = null;
            string? prev = null;
            string? next = null;

            if (before != null) {
                child = before.get_child () as ListItem;
                prev = child.get_item_category ();
            }

            if (after != null) {
                child = after.get_child () as ListItem;
                next = child.get_item_category ();
            }

            if (before == null || after == null || prev != next) {
                Gtk.Label label = new Gtk.Label (GLib.Markup.printf_escaped ("<span font=\"13\">%s</span>", prev));
                label.set_halign (Gtk.Align.CENTER);
                label.set_use_markup (true);
                before.set_header (label);
                label.margin = 5;
            } else {
                before.set_header (null);
            }
        }

        public void refresh_mounts() {
            foreach (Gtk.Widget item in vol_listbox.get_children()) {
                item.destroy ();
            }
            // Add volumes connected with a drive
            foreach (GLib.Drive drive in volume_monitor.get_connected_drives ()) {
                foreach (GLib.Volume volume in drive.get_volumes ()) {
                    GLib.Mount mount = volume.get_mount ();

                    if (mount == null) {
                        add_volume (volume);
                    } else {
                        add_mount (mount, volume.get_identifier ("class"));
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
                    add_volume (volume);
                } else {
                    add_mount (mount, volume.get_identifier ("class"));
                }
            }
            // Add mounts without volumes
            foreach (GLib.Mount mount in volume_monitor.get_mounts ()) {
                if (mount.is_shadowed () || mount.get_volume () != null) {
                    continue;
                }

                GLib.File root = mount.get_default_location ();
                if (!root.is_native ()) {
                    add_mount (mount, "network");
                } else {
                    add_mount (mount, "device");
                }
            }

            get_child_at (0, 1).show_all ();
        }

        private void add_volume (GLib.Volume volume) {
            VolumeItem volume_item = new VolumeItem (volume);
            volume_item.mount_done.connect ((file) => {
                open_directory (file);
            });

            vol_listbox.add (volume_item);
        }

        private void add_mount (GLib.Mount mount, string? mount_class) {
            MountItem mount_item = new MountItem (mount, mount_class);
            mount_item.iter_button.clicked.connect (() => {
                open_directory (mount.get_root ());
            });
            mount_item.unmount_end.connect (() => {
                refresh_mounts ();
            });

            vol_listbox.add (mount_item);
        }
    }
}
