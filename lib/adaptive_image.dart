import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveImage extends StatelessWidget {
  AdaptiveImage.network(String url, {super.key}) {
    // Para web, usar URLs directas de YouTube sin proxy
    // Para móvil, usar el proxy CORS si está disponible
    _url = url;
  }

  late final String _url;

  @override
  Widget build(BuildContext context) {
    return Image.network(_url);
  }
}