import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareWidgetAsImage(GlobalKey globalKey) async {
    try {
      final boundary = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      // 🌐 WEB ORTAMI KONTROLÜ
      if (kIsWeb) {
        final xFile = XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: 'my_routine_stats.png',
        );
        
        await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
            text: 'İşte benim rutin ve alışkanlık gelişimim! 🔥🚀',
          ),
        );
      } else {
        // 📱 MOBİL / MASAÜSTÜ ORTAMI
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/my_routine_stats.png').create();
        await file.writeAsBytes(pngBytes);

        final xFile = XFile(file.path);
        
        await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
            text: 'İşte benim rutin ve alışkanlık gelişimim! 🔥🚀',
          ),
        );
      }
    } catch (e) {
      debugPrint('Paylaşım hatası: $e');
    }
  }
}