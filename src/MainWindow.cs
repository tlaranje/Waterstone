using Avalonia;
using Avalonia.Controls;
using Avalonia.Media;
using System;
using System.Runtime.InteropServices;

namespace src;

public static class X11ClickThrough
{
    [DllImport("libX11.so.6")]
    private static extern IntPtr XOpenDisplay(string? display);

    [DllImport("libX11.so.6")]
    private static extern int XShapeCombineRectangles(
        IntPtr display, IntPtr window,
        int dest_kind, int x_off, int y_off,
        IntPtr rectangles, int n_rects,
        int op, int ordering);

    [DllImport("libXfixes.so.3")]
    private static extern void XFixesSetWindowShapeRegion(
        IntPtr display, IntPtr window,
        int shape_kind, int x_off, int y_off,
        IntPtr region);

    [DllImport("libXfixes.so.3")]
    private static extern IntPtr XFixesCreateRegion(
        IntPtr display, IntPtr rectangles, int n_rects);

    private const int ShapeInput = 2;

    public static void SetClickThrough(Window window)
    {
        var handle = window.TryGetPlatformHandle()?.Handle;
        if (handle == null) return;

        var display = XOpenDisplay(null);
        if (display == IntPtr.Zero) return;

        var region = XFixesCreateRegion(display, IntPtr.Zero, 0);
        XFixesSetWindowShapeRegion(display, handle.Value, ShapeInput, 0, 0, region);
    }
}

public partial class MainWindow : Window
{
    public MainWindow()
    {
        // Propriedades da janela
        Title = "Overlay";
        Width = 800;
        Height = 600;
        Topmost = true;
        Background = Brushes.Transparent;
        TransparencyLevelHint = new[] { WindowTransparencyLevel.Transparent };

        // UI
        var stack = new StackPanel
        {
            Spacing = 10,
            Margin = new Thickness(20)
        };

        var texto = new TextBlock
        {
            Text = "Overlay",
            Foreground = Brushes.White,
            FontSize = 24
        };

        stack.Children.Add(texto);
        Content = stack;
        this.Opened += (_, _) => X11ClickThrough.SetClickThrough(this);
    }
}
