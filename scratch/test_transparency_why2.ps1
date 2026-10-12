$csharp = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class WhyChooseTransparency {
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

                // BFS flood fill from background borders
                bool[] isBg = new bool[w * h];
                int[] qx = new int[w * h];
                int[] qy = new int[w * h];
                int head = 0, tail = 0;

                // Function to check if a pixel is definitely background
                // Background color in these images: R <= 20, G <= 58, B <= 52
                Func<byte, byte, byte, bool> isBgColor = (b, g, r) => {
                    // Check if it's the dark green background
                    if (r <= 20 && g <= 58 && b <= 52) return true;
                    // Also dark shadow on the background
                    if (r <= 12 && g <= 30 && b <= 30) return true;
                    return false;
                };

                // Seed top border (where it's background, avoiding tape if tape touches edge)
                for (int x = 0; x < w; x++) {
                    int bidx = (x * 4);
                    byte b = srcBytes[bidx];
                    byte g = srcBytes[bidx + 1];
                    byte r = srcBytes[bidx + 2];
                    if (isBgColor(b, g, r)) {
                        qx[tail] = x; qy[tail] = 0; isBg[x] = true; tail++;
                    }
                }

                // Seed bottom border (avoiding emeralds)
                for (int x = 0; x < w; x++) {
                    int bidx = (h - 1) * srcData.Stride + (x * 4);
                    byte b = srcBytes[bidx];
                    byte g = srcBytes[bidx + 1];
                    byte r = srcBytes[bidx + 2];
                    if (isBgColor(b, g, r)) {
                        qx[tail] = x; qy[tail] = h - 1; isBg[(h - 1) * w + x] = true; tail++;
                    }
                }

                // Seed left & right borders (avoiding emeralds)
                for (int y = 0; y < h; y++) {
                    int bidxL = y * srcData.Stride;
                    if (!isBg[y * w] && isBgColor(srcBytes[bidxL], srcBytes[bidxL + 1], srcBytes[bidxL + 2])) {
                        qx[tail] = 0; qy[tail] = y; isBg[y * w] = true; tail++;
                    }
                    int bidxR = y * srcData.Stride + ((w - 1) * 4);
                    if (!isBg[y * w + (w - 1)] && isBgColor(srcBytes[bidxR], srcBytes[bidxR + 1], srcBytes[bidxR + 2])) {
                        qx[tail] = w - 1; qy[tail] = y; isBg[y * w + (w - 1)] = true; tail++;
                    }
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
                                byte b = srcBytes[bidx];
                                byte g = srcBytes[bidx + 1];
                                byte r = srcBytes[bidx + 2];

                                if (isBgColor(b, g, r)) {
                                    isBg[nidx] = true;
                                    qx[tail] = nx;
                                    qy[tail] = ny;
                                    tail++;
                                }
                            }
                        }
                    }
                }

                // Copy pixels: if background -> alpha = 0, else keep original
                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int idx = y * w + x;
                        int bidx = y * srcData.Stride + (x * 4);

                        if (isBg[idx]) {
                            destBytes[bidx] = 0;
                            destBytes[bidx + 1] = 0;
                            destBytes[bidx + 2] = 0;
                            destBytes[bidx + 3] = 0;
                        } else {
                            destBytes[bidx] = srcBytes[bidx];
                            destBytes[bidx + 1] = srcBytes[bidx + 1];
                            destBytes[bidx + 2] = srcBytes[bidx + 2];
                            destBytes[bidx + 3] = 255;
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
[WhyChooseTransparency]::Process("c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2.png", "c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_why2_transparent.png")
Write-Host "Processed test_why2_transparent.png successfully!"
