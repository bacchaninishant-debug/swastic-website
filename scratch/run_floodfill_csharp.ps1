$csharp = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public class FloodFillTest {
    public static void Run(string srcPath, string destPath) {
        byte[] bytes = File.ReadAllBytes(srcPath);
        using (MemoryStream ms = new MemoryStream(bytes))
        using (Bitmap bmp = new Bitmap(ms)) {
            int w = bmp.Width;
            int h = bmp.Height;
            Rectangle rect = new Rectangle(0, 0, w, h);
            BitmapData bd = bmp.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            int totalBytes = Math.Abs(bd.Stride) * h;
            byte[] srcBytes = new byte[totalBytes];
            Marshal.Copy(bd.Scan0, srcBytes, 0, totalBytes);
            bmp.UnlockBits(bd);

            bool[] isBg = new bool[w * h];
            Queue<int> q = new Queue<int>();

            // Check if pixel at (x, y) is background
            Func<int, int, bool> isBgPixel = (x, y) => {
                int idx = y * bd.Stride + (x * 4);
                byte b = srcBytes[idx];
                byte g = srcBytes[idx + 1];
                byte r = srcBytes[idx + 2];
                // Background criteria:
                // R <= 18, G in [22..55], B in [22..52], |G - B| <= 8
                return (r <= 18 && g >= 22 && g <= 55 && b >= 22 && b <= 52 && Math.Abs(g - b) <= 8);
            };

            // Seed from edges
            for (int x = 0; x < w; x++) {
                if (isBgPixel(x, 0)) { isBg[0 * w + x] = true; q.Enqueue(0 * w + x); }
                if (isBgPixel(x, h - 1)) { isBg[(h - 1) * w + x] = true; q.Enqueue((h - 1) * w + x); }
            }
            for (int y = 0; y < h; y++) {
                if (isBgPixel(0, y)) { isBg[y * w + 0] = true; q.Enqueue(y * w + 0); }
                if (isBgPixel(w - 1, y)) { isBg[y * w + (w - 1)] = true; q.Enqueue(y * w + (w - 1)); }
            }

            int[] dx = { 0, 0, 1, -1 };
            int[] dy = { 1, -1, 0, 0 };

            while (q.Count > 0) {
                int curr = q.Dequeue();
                int cx = curr % w;
                int cy = curr / w;

                for (int i = 0; i < 4; i++) {
                    int nx = cx + dx[i];
                    int ny = cy + dy[i];
                    if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
                        int nidx = ny * w + nx;
                        if (!isBg[nidx] && isBgPixel(nx, ny)) {
                            isBg[nidx] = true;
                            q.Enqueue(nidx);
                        }
                    }
                }
            }

            // Create output image
            using (Bitmap dest = new Bitmap(w, h, PixelFormat.Format32bppArgb)) {
                BitmapData destData = dest.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
                byte[] destBytes = new byte[totalBytes];

                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int idx = y * w + x;
                        int bidx = y * bd.Stride + (x * 4);
                        if (!isBg[idx]) {
                            destBytes[bidx] = srcBytes[bidx];
                            destBytes[bidx + 1] = srcBytes[bidx + 1];
                            destBytes[bidx + 2] = srcBytes[bidx + 2];
                            destBytes[bidx + 3] = 255; // solid
                        } else {
                            destBytes[bidx] = 0;
                            destBytes[bidx + 1] = 0;
                            destBytes[bidx + 2] = 0;
                            destBytes[bidx + 3] = 0; // transparent
                        }
                    }
                }

                Marshal.Copy(destBytes, 0, destData.Scan0, totalBytes);
                dest.UnlockBits(destData);
                dest.Save(destPath, ImageFormat.Png);
            }
            Console.WriteLine("Flood fill transparent saved to: " + destPath);
        }
    }
}
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"
[FloodFillTest]::Run("c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\panorama_test.png", "c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\panorama_transparent.png")
