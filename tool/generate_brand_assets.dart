// Menurunkan aset persegi dari banner ikon sumber (assets/icon/icon-app.jpeg).
// Jalankan sekali: dart run tool/generate_brand_assets.dart
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final source =
      img.decodeImage(File('assets/icon/icon-app.jpeg').readAsBytesSync())!;

  var minX = source.width, minY = source.height, maxX = 0, maxY = 0;
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final p = source.getPixel(x, y);
      final isGreen = p.g > p.r + 10 && p.g > p.b + 5;
      if (isGreen) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  final tileW = maxX - minX + 1;
  final tileH = maxY - minY + 1;
  final side = tileW < tileH ? tileW : tileH;
  final left = minX + (tileW - side) ~/ 2;
  final top = minY + (tileH - side) ~/ 2;
  stdout.writeln('tile bbox: $minX,$minY ${tileW}x$tileH; square crop $side');

  // Warna hijau dominan pada bagian atas ubin (area tanpa teks).
  var r = 0, g = 0, b = 0, count = 0;
  for (var y = minY + (tileH * 0.12).round();
      y < minY + (tileH * 0.2).round();
      y++) {
    for (var x = minX + (tileW * 0.3).round();
        x < minX + (tileW * 0.7).round();
        x++) {
      final p = source.getPixel(x, y);
      if (p.g > p.r + 10 && p.g > p.b + 5) {
        r += p.r.toInt();
        g += p.g.toInt();
        b += p.b.toInt();
        count++;
      }
    }
  }
  final brandColor =
      '#${(r ~/ count).toRadixString(16).padLeft(2, '0')}'
      '${(g ~/ count).toRadixString(16).padLeft(2, '0')}'
      '${(b ~/ count).toRadixString(16).padLeft(2, '0')}';
  stdout.writeln('brand color: $brandColor');

  final squareTile = img.copyCrop(
    source,
    x: left,
    y: top,
    width: side,
    height: side,
  ).convert(numChannels: 4);

  // Buat area putih di luar sudut membulat menjadi transparan.
  final visited = List.generate(side, (_) => List.filled(side, false));
  // Latar putih dan garis tepi terang pada ubin dianggap background.
  bool isBackground(img.Pixel p) {
    final r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
    final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
    final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
    final luma = 0.299 * r + 0.587 * g + 0.114 * b;
    return luma > 160 && (maxC - minC) < 50;
  }

  final queue = <List<int>>[];
  for (var i = 0; i < side; i++) {
    queue
      ..add([i, 0])
      ..add([i, side - 1])
      ..add([0, i])
      ..add([side - 1, i]);
  }
  while (queue.isNotEmpty) {
    final point = queue.removeLast();
    final x = point[0], y = point[1];
    if (x < 0 || y < 0 || x >= side || y >= side || visited[y][x]) continue;
    visited[y][x] = true;
    final p = squareTile.getPixel(x, y);
    if (!isBackground(p)) continue;
    squareTile.setPixelRgba(x, y, p.r, p.g, p.b, 0);
    queue
      ..add([x + 1, y])
      ..add([x - 1, y])
      ..add([x, y + 1])
      ..add([x, y - 1]);
  }

  // Ubah bagian putih logo menjadi putih transparan agar menyatu dengan
  // latar hijau splash/adaptive icon tanpa menyisakan kotak.
  final whiteLogoSource = img.Image(
    width: squareTile.width,
    height: squareTile.height,
    numChannels: 4,
  );
  // Masker rounded-rectangle: membuang garis tepi ubin, tetapi tetap
  // mempertahankan seluruh tulisan HADISKU di bagian bawah logo.
  final size = squareTile.width.toDouble();
  final inset = size * 0.015;
  final cornerRadius = size * 0.12;
  final innerLeft = inset + cornerRadius;
  final innerRight = size - inset - cornerRadius;

  bool insideRoundedRect(int x, int y) {
    final dx =
        (innerLeft - x) > (x - innerRight) ? (innerLeft - x) : (x - innerRight);
    final dy =
        (innerLeft - y) > (y - innerRight) ? (innerLeft - y) : (y - innerRight);
    final clampedDx = dx > 0 ? dx : 0.0;
    final clampedDy = dy > 0 ? dy : 0.0;
    return clampedDx * clampedDx + clampedDy * clampedDy <
        cornerRadius * cornerRadius;
  }

  for (var y = 0; y < squareTile.height; y++) {
    for (var x = 0; x < squareTile.width; x++) {
      final p = squareTile.getPixel(x, y);
      if (p.a == 0) continue;
      if (!insideRoundedRect(x, y)) continue;
      final luma = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
      final alpha = ((luma - 190) / 55 * 255).clamp(0, 255).round();
      if (alpha > 0) {
        whiteLogoSource.setPixelRgba(x, y, 255, 255, 255, alpha);
      }
    }
  }

  final transparentTile = img.copyResize(
    whiteLogoSource,
    width: 1024,
    height: 1024,
    interpolation: img.Interpolation.linear,
  );

  void writePng(img.Image image, String path) {
    File(path).writeAsBytesSync(img.encodePng(image, level: 6));
    stdout.writeln('wrote $path');
  }

  // Logo splash: ubin dengan ruang kosong di sekelilingnya.
  final splash = img.Image(width: 1024, height: 1024, numChannels: 4);
  final splashLogo = img.copyResize(
    transparentTile,
    width: 800,
    height: 800,
    interpolation: img.Interpolation.cubic,
  );
  img.compositeImage(splash, splashLogo, dstX: 112, dstY: 112);
  writePng(splash, 'assets/icon/splash-logo.png');

  // Foreground adaptive icon: logo berada dalam safe zone Android.
  final adaptive = img.Image(width: 1024, height: 1024, numChannels: 4);
  final adaptiveLogo = img.copyResize(
    transparentTile,
    width: 640,
    height: 640,
    interpolation: img.Interpolation.cubic,
  );
  img.compositeImage(adaptive, adaptiveLogo, dstX: 192, dstY: 192);
  writePng(adaptive, 'assets/icon/icon-adaptive-foreground.png');

  // Ikon persegi penuh untuk iOS/legacy/web: potong di dalam sudut ubin.
  final solidSide = (side * 0.82).round();
  final solid = img.copyResize(
    img.copyCrop(
      source,
      x: left + (side - solidSide) ~/ 2,
      y: top + (side - solidSide) ~/ 2,
      width: solidSide,
      height: solidSide,
    ),
    width: 1024,
    height: 1024,
    interpolation: img.Interpolation.cubic,
  );
  writePng(solid, 'assets/icon/icon-app-solid.png');
}
