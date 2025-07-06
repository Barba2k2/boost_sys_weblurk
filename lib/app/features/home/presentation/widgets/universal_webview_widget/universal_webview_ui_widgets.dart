import 'package:flutter/material.dart';

class UniversalWebViewUIWidgets {
  static Widget buildErrorWidget({
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              SelectableText(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildProgressIndicator({
    required ValueNotifier<double> loadingProgress,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: loadingProgress,
      builder: (context, progress, _) {
        return LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.black12,
          color: Colors.purple,
        );
      },
    );
  }

  static Widget buildLoadingIndicator({
    required bool isLoading,
  }) {
    return Positioned(
      top: 10,
      right: 10,
      child: isLoading
          ? const CircularProgressIndicator.adaptive(strokeWidth: 2)
          : Container(),
    );
  }

  static Widget buildMuteIndicator() {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.volume_off,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
} 