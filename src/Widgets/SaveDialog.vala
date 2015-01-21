/***
  BEGIN LICENSE

  Copyright (C) 2014-2015 Fabio Zaramella <ffabio.96.x@gmail.com>

  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License version 3, as
  published    by the Free Software Foundation.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranties of
  MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
  PURPOSE.  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program.  If not, see <http://www.gnu.org/licenses>

  END LICENSE
***/

namespace Screenshot.Widgets {

    public class SaveDialog : Gtk.Dialog {

        private Gtk.Grid            grid;
        private Gtk.Label           dialog_label;
        private Gtk.Label           name_label;
        private Gtk.Entry           name_entry;
        private Gtk.Label           format_label;
        private Gtk.ComboBoxText    format_cmb;
        private Gtk.Button          save_btn;
        private Gtk.Button          retry_btn;

        private string  file_name;
        private string  date_time;
        private string  folder_dir;

        public signal void save_response (bool response, string folder_dir, string output_name, string format);

        public SaveDialog (Settings settings, Gtk.Window parent, bool include_date) {

            resizable = false;
            deletable = false;
            modal = true;
            set_keep_above (true);
            set_transient_for (parent);
            window_position = Gtk.WindowPosition.CENTER;
            
            folder_dir = Environment.get_user_special_dir (UserDirectory.PICTURES);

            if (settings.get_string ("folder-dir") != folder_dir && settings.get_string ("folder-dir") != "")
                folder_dir = settings.get_string ("folder-dir");

            build (settings, parent, include_date);
            show_all ();
            name_entry.grab_focus ();
        }

        public void build (Settings settings, Gtk.Window parent, bool include_date) {

            date_time = (include_date ? new GLib.DateTime.now_local ().format ("%d-%m-%Y %H:%M:%S") : new GLib.DateTime.now_local ().format ("%H:%M:%S"));
            file_name = _("screenshot ") + date_time;

            grid = new Gtk.Grid (); 
            grid.row_spacing = 12;
            grid.column_spacing = 12;
            grid.margin_start = 12;
            grid.margin_end = 12;

            var content = this.get_content_area () as Gtk.Box;

            dialog_label = new Gtk.Label ("");
            dialog_label.halign = Gtk.Align.START;
            dialog_label.set_markup ("<b>" + _("Save the image as...") + "</b>");

            name_label = new Gtk.Label (_("Name:"));
            name_label.halign = Gtk.Align.END;
            name_entry = new Gtk.Entry ();
            name_entry.set_text (file_name);
            name_entry.set_width_chars (35);

            format_label = new Gtk.Label (_("Format:"));
            format_label.halign = Gtk.Align.END;

            /**
             *  Create combobox for file format
             */
            format_cmb = new Gtk.ComboBoxText ();
            format_cmb.append_text ("png");
            format_cmb.append_text ("jpeg");
            format_cmb.append_text ("bmp");

            switch (settings.get_string ("format")) {
                case "png":
                    format_cmb.active = 0;
                    break;
                case "jpeg":
                    format_cmb.active = 1;
                    break;
                case "bmp":
                    format_cmb.active = 2;
                    break;
            }

            var location_label = new Gtk.Label (_("Folder:"));
            location_label.halign = Gtk.Align.END;
            var location = new Gtk.FileChooserButton (_("Select Screenshots Folder…"), Gtk.FileChooserAction.SELECT_FOLDER);

            location.set_current_folder (folder_dir);

            save_btn = new Gtk.Button.with_label (_("Save"));
            retry_btn = new Gtk.Button.with_label (_("Cancel"));

            save_btn.get_style_context ().add_class ("suggested-action");

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            box.pack_end (save_btn, false, true, 0);
            box.pack_end (retry_btn, false, true, 0);
            box.homogeneous = true;

            save_btn.clicked.connect (() => {
                save_response (true, folder_dir, name_entry.get_text (), format_cmb.get_active_text ());
            });

            retry_btn.clicked.connect (() => {
                save_response (false, folder_dir, file_name, format_cmb.get_active_text ());
            });

            format_cmb.changed.connect (() => {
                settings.set_string ("format", format_cmb.get_active_text ());
		    });

            location.selection_changed.connect (() => {
			    SList<string> uris = location.get_uris ();
			    foreach (unowned string uri in uris) {
				    settings.set_string ("folder-dir", uri.substring (7, -1));
                    folder_dir = settings.get_string ("folder-dir");
			    }
		    });

            key_press_event.connect ((e) => {
                if (e.keyval == Gdk.Key.Return)
                    save_btn.activate ();

                return false;
            });

            grid.attach (dialog_label, 1, 0, 1, 1);
            grid.attach (name_label, 0, 1, 1, 1);
            grid.attach (name_entry, 1, 1, 1, 1);
            grid.attach (format_label, 0, 2, 1, 1);
            grid.attach (format_cmb, 1, 2, 1, 1);
            grid.attach (location_label, 0, 3, 1, 1);
            grid.attach (location, 1, 3, 1, 1);
            grid.attach (box, 1, 4, 1, 1);

            content.add (grid);
        }
    }
}
