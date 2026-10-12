$csharp = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class ImageTransparency {
    public static void Process(string srcPath, string destPath) {
        using (Bitmap src = new Bitmap(srcPath)) {
            int w = src.Width;
            int h = src.Height;
            using (Bitmap dest = new Bitmap(w, h, PixelFormat.Format32bppArgb)) {
                Rectangle rect = new Rectangle(0, 0, w, h);
                BitmapData srcData = src.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
                BitmapData destData = dest.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);

                int bytes = Math.Abs(srcData.Stride) * h;
                byte[] srcBytes = new byte[bytes];
                byte[] destBytes = new byte[bytes];
                Marshal.Copy(srcData.Scan0, srcBytes, 0, bytes);

                bool[] isBg = new bool[w * h];
                int[] qx = new int[w * h];
                int[] qy = new int[w * h];
                int head = 0, tail = 0;

                for (int x = 0; x < w; x++) {
                    qx[tail] = x; qy[tail] = 0; isBg[x] = true; tail++;
                    qx[tail] = x; qy[tail] = h - 1; isBg[(h - 1) * w + x] = true; tail++;
                }
                for (int y = 0; y < h; y++) {
                    if (!isBg[y * w]) { qx[tail] = 0; qy[tail] = y; isBg[y * w] = true; tail++; }
                    if (!isBg[y * w + (w - 1)]) { qx[tail] = w - 1; qy[tail] = y; isBg[y * w + (w - 1)] = true; tail++; }
                }

                int[] dx = { 1, -1, 0, 0 };
                int[] dy = { 0, 0, 1, -1 };

                while (head < tail) {
                    int cx = qx[head];
                    int cy = qy[head];
                    head++;

                    for (int i = 0; i < 4; i++) {
                        int nx = cx + dx[i];
                        int ny = cy + dy[i];
                        if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
                            int nidx = ny * w + nx;
                            if (!isBg[nidx]) {
                                int bidx = ny * srcData.Stride + (nx * 4);
                                int b = srcBytes[bidx];
                                int g = srcBytes[bidx + 1];
                                int r = srcBytes[bidx + 2];
                                int min = Math.Min(r, Math.Min(g, b));
                                if (min >= 244) {
                                    isBg[nidx] = true;
                                    qx[tail] = nx;
                                    qy[tail] = ny;
                                    tail++;
                                }
                            }
                        }
                    }
                }

                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int idx = y * w + x;
                        int bidx = y * srcData.Stride + (x * 4);

                        if (x > 840 && y > 640) {
                            destBytes[bidx] = 0; destBytes[bidx+1] = 0; destBytes[bidx+2] = 0; destBytes[bidx+3] = 0;
                            continue;
                        }

                        if (isBg[idx]) {
                            destBytes[bidx] = 0; destBytes[bidx+1] = 0; destBytes[bidx+2] = 0; destBytes[bidx+3] = 0;
                        } else {
                            byte b = srcBytes[bidx];
                            byte g = srcBytes[bidx + 1];
                            byte r = srcBytes[bidx + 2];

                            int min = Math.Min(r, Math.Min(g, b));
                            double diff = 255.0 - min;

                            double alpha = 1.0;
                            if (diff < 42.0) {
                                alpha = Math.Max(0.0, Math.Min(1.0, (diff - 4.0) / 36.0));
                            }

                            if (alpha > 0.05) {
                                double unmixR = Math.Max(0.0, Math.Min(255.0, (r - 255.0 * (1.0 - alpha)) / alpha));
                                double unmixG = Math.Max(0.0, Math.Min(255.0, (g - 255.0 * (1.0 - alpha)) / alpha));
                                double unmixB = Math.Max(0.0, Math.Min(255.0, (b - 255.0 * (1.0 - alpha)) / alpha));

                                destBytes[bidx] = (byte)Math.Round(unmixB);
                                destBytes[bidx + 1] = (byte)Math.Round(unmixG);
                                destBytes[bidx + 2] = (byte)Math.Round(unmixR);
                                destBytes[bidx + 3] = (byte)Math.Round(alpha * 255.0);
                            } else {
                                destBytes[bidx] = 0; destBytes[bidx+1] = 0; destBytes[bidx+2] = 0; destBytes[bidx+3] = 0;
                            }
                        }
                    }
                }

                Marshal.Copy(destBytes, 0, destData.Scan0, bytes);
                src.UnlockBits(srcData);
                dest.UnlockBits(destData);
                dest.Save(destPath, ImageFormat.Png);
            }
        }
    }
}
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"
[ImageTransparency]::Process("c:\Users\User\OneDrive\Desktop\veloraaaa\images\swastic-gems-hero.jpg", "c:\Users\User\OneDrive\Desktop\veloraaaa\images\swastic-gems-hero.png")
Write-Host "C# ImageTransparency completed!"
