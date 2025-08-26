import 'package:flutter/material.dart';

/// Model representing the current state of an update process
class UpdateProgressModel {
  final String title;
  final String description;
  final IconData icon;
  final double value;
  final bool showDeterminate;
  final bool showPercentage;
  final UpdateStage stage;

  const UpdateProgressModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.stage,
    this.value = 0.0,
    this.showDeterminate = false,
    this.showPercentage = false,
  });

  UpdateProgressModel copyWith({
    String? title,
    String? description,
    IconData? icon,
    UpdateStage? stage,
    double? value,
    bool? showDeterminate,
    bool? showPercentage,
  }) {
    return UpdateProgressModel(
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      stage: stage ?? this.stage,
      value: value ?? this.value,
      showDeterminate: showDeterminate ?? this.showDeterminate,
      showPercentage: showPercentage ?? this.showPercentage,
    );
  }

  // Factory constructors for different stages
  static const initializing = UpdateProgressModel(
    title: 'Inicializando...',
    description: 'Preparando a atualização.',
    icon: Icons.settings,
    stage: UpdateStage.initializing,
  );

  static const checking = UpdateProgressModel(
    title: 'Verificando...',
    description: 'Checando a disponibilidade da atualização.',
    icon: Icons.search,
    stage: UpdateStage.checking,
  );

  static const downloading = UpdateProgressModel(
    title: 'Baixando...',
    description: 'Fazendo download da atualização.',
    icon: Icons.download,
    stage: UpdateStage.downloading,
    showDeterminate: true,
    showPercentage: true,
  );

  static const installing = UpdateProgressModel(
    title: 'Instalando...',
    description: 'Aplicando a atualização.',
    icon: Icons.build,
    stage: UpdateStage.installing,
    value: 1.0,
    showDeterminate: true,
  );

  static const finalizing = UpdateProgressModel(
    title: 'Finalizando...',
    description: 'Concluindo a instalação.',
    icon: Icons.check_circle_outline,
    stage: UpdateStage.finalizing,
  );

  static const complete = UpdateProgressModel(
    title: 'Concluído!',
    description: 'Atualização aplicada com sucesso.',
    icon: Icons.check_circle,
    stage: UpdateStage.complete,
    value: 1.0,
    showDeterminate: true,
  );
}

/// Enum representing different stages of the update process
enum UpdateStage {
  initializing,
  checking,
  downloading,
  installing,
  finalizing,
  complete,
  error,
}

/// Model for update availability information
class UpdateInfoModel {
  final bool hasUpdate;
  final String? currentPatchNumber;
  final String? availablePatchNumber;
  final DateTime? lastChecked;

  const UpdateInfoModel({
    required this.hasUpdate,
    this.currentPatchNumber,
    this.availablePatchNumber,
    this.lastChecked,
  });

  UpdateInfoModel copyWith({
    bool? hasUpdate,
    String? currentPatchNumber,
    String? availablePatchNumber,
    DateTime? lastChecked,
  }) {
    return UpdateInfoModel(
      hasUpdate: hasUpdate ?? this.hasUpdate,
      currentPatchNumber: currentPatchNumber ?? this.currentPatchNumber,
      availablePatchNumber: availablePatchNumber ?? this.availablePatchNumber,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}