// lib/widgets/loading_overlay.dart

import 'package:flutter/material.dart';

/// Виджет оверлея загрузки, который отображается поверх контента
/// во время выполнения асинхронных операций.
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Color? backgroundColor;
  final Color? textColor;
  final double opacity;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.backgroundColor,
    this.textColor,
    this.opacity = 0.7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Основной контент
        child,
        
        // Оверлей загрузки
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: (backgroundColor ?? Colors.black).withOpacity(opacity),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Индикатор загрузки
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.white,
                      ),
                    ),
                    
                    // Текст загрузки (если указан)
                    if (loadingText != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        loadingText!,
                        style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}