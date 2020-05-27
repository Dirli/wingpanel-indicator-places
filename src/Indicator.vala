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

namespace Places {
    public class Indicator : Wingpanel.Indicator {
        private Widgets.Popover? main_widget = null;
        private Gtk.Box? panel_label = null;

        public Indicator () {
            Object (code_name : "places-indicator",
                    display_name : "Places Indicator",
                    description: _("Manage disks, volumes, places from the panel."));

            Gtk.IconTheme.get_default().add_resource_path("/io/elementary/desktop/wingpanel/places");

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

        public override void opened () {
            main_widget.refresh_mounts ();
        }

        public override void closed () {}
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
