using System;
using System.Runtime.InteropServices;
using Gtk;
using Gdk;

class Program
{
    [DllImport("libgtk-layer-shell.so")]
    static extern void gtk_layer_init_for_window(IntPtr window);

    [DllImport("libgtk-layer-shell.so")]
    static extern void gtk_layer_set_layer(IntPtr window, int layer);

    [DllImport("libgtk-layer-shell.so")]
    static extern void gtk_layer_set_anchor(IntPtr window, int edge, bool anchor);

    [DllImport("libgtk-layer-shell.so")]
    static extern void gtk_layer_set_keyboard_interactivity(IntPtr window, bool interactable);

    static void Main(string[] args)
    {
        Application.Init();

        // CSS para forçar transparência antes de qualquer desenho
        var css = new CssProvider();
        css.LoadFromData("window, fixed, label { background: transparent; }");
        StyleContext.AddProviderForScreen(
            Gdk.Screen.Default,
            css,
            StyleProviderPriority.Application
        );

        Gtk.Window win = new Gtk.Window("WaterstoneOverlay");

        if (win.Screen.RgbaVisual != null) win.Visual = win.Screen.RgbaVisual;
        win.AppPaintable = true;
        win.Decorated = false;
        win.KeepAbove = true;

        win.Drawn += (o, a) =>
        {
            a.Cr.Save();
            a.Cr.SetSourceRGBA(0, 0, 0, 0);
            a.Cr.Operator = Cairo.Operator.Clear;
            a.Cr.Paint();
            a.Cr.Restore();
        };

        string? session = Environment.GetEnvironmentVariable("XDG_SESSION_TYPE")?.ToLower();

        if (session == "wayland")
        {
            try
            {
                gtk_layer_init_for_window(win.Handle);
                gtk_layer_set_layer(win.Handle, 3);
                for (int i = 0; i < 4; i++) gtk_layer_set_anchor(win.Handle, i, true);
                gtk_layer_set_keyboard_interactivity(win.Handle, false);
                Console.WriteLine("Modo: Wayland Layer Shell");
            }
            catch
            {
                Console.WriteLine("Erro ao carregar libgtk-layer-shell.so");
            }
        }
        else
        {
            win.TypeHint = WindowTypeHint.Dock;
            win.AcceptFocus = false;
            win.Fullscreen();
            Console.WriteLine("Modo: X11 Transparent Overlay");
        }

        win.Realized += (s, e) =>
        {
            using (Cairo.Region region = new Cairo.Region())
            {
                win.Window.InputShapeCombineRegion(region, 0, 0);
            }
        };

        // UI
        Fixed container = new Fixed();
        Label label = new Label("<span foreground='#00FF00' size='30000'><b>SISTEMA DE OVERLAY V2</b></span>");
        label.UseMarkup = true;
        container.Put(label, 100, 100);
        win.Add(container);
        win.ShowAll();

        Application.Run();
    }
}