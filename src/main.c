#include <gtk/gtk.h>
#include <gtk4-layer-shell.h>
#include <gdk/wayland/gdkwayland.h>
#include <wayland-client.h>

// ── Layer shell ─────────────────────────────────────────────────────────────

static void setup_layer(GtkWindow *win)
{
	gtk_layer_init_for_window(win);
	gtk_layer_set_layer(win, GTK_LAYER_SHELL_LAYER_OVERLAY);
	gtk_layer_set_namespace(win, "hs-overlay");
	gtk_layer_set_keyboard_mode(win, GTK_LAYER_SHELL_KEYBOARD_MODE_NONE);

	gtk_layer_set_anchor(win, GTK_LAYER_SHELL_EDGE_TOP, TRUE);
	gtk_layer_set_anchor(win, GTK_LAYER_SHELL_EDGE_LEFT, TRUE);
	gtk_layer_set_anchor(win, GTK_LAYER_SHELL_EDGE_RIGHT, TRUE);

	gtk_layer_set_margin(win, GTK_LAYER_SHELL_EDGE_TOP, 10);
	gtk_widget_set_size_request(GTK_WIDGET(win), -1, 40);
}

// ── Visuals ─────────────────────────────────────────────────────────────────

static void setup_style(GtkWindow *win)
{
	gtk_widget_set_name(GTK_WIDGET(win), "overlay-win");

	GtkCssProvider *css = gtk_css_provider_new();
	gtk_css_provider_load_from_string(
		css, "#overlay-win { background: transparent; }"
	);
	gtk_style_context_add_provider_for_display(
		gtk_widget_get_display(GTK_WIDGET(win)),
		GTK_STYLE_PROVIDER(css),
		GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
}

// ── Input passthrough ───────────────────────────────────────────────────────

static void on_realize(GtkWidget *widget, gpointer data)
{
	(void)data;

	GdkDisplay *display = gtk_widget_get_display(widget);
	GdkSurface *surface = gtk_native_get_surface(GTK_NATIVE(widget));

	struct wl_compositor *c = gdk_wayland_display_get_wl_compositor(display);
	struct wl_surface *wl_s = gdk_wayland_surface_get_wl_surface(surface);

	// Empty region = compositor passes all input through to windows below
	struct wl_region *region = wl_compositor_create_region(c);
	wl_surface_set_input_region(wl_s, region);
	wl_region_destroy(region);
	wl_surface_commit(wl_s);
}

// ── Content ─────────────────────────────────────────────────────────────────

static void setup_content(GtkWindow *win)
{
	gtk_window_set_child(win, gtk_label_new("HS_Overlay"));
}

// ── App entry ───────────────────────────────────────────────────────────────

static void on_activate(GtkApplication *app, gpointer data)
{
	(void)data;

	GtkWindow *win = GTK_WINDOW(gtk_application_window_new(app));

	setup_layer(win);
	setup_style(win);
	setup_content(win);

	g_signal_connect(win, "realize", G_CALLBACK(on_realize), NULL);
	gtk_window_present(win);
}

int main(int argc, char **argv)
{
	GtkApplication *app = gtk_application_new(
		"com.hs.overlay", G_APPLICATION_DEFAULT_FLAGS
	);
	g_signal_connect(app, "activate", G_CALLBACK(on_activate), NULL);

	int status = g_application_run(G_APPLICATION(app), argc, argv);
	g_object_unref(app);
	return status;
}