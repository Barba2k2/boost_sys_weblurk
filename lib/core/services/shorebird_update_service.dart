import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Core service responsible for Shorebird update operations
/// This service contains only business logic, no UI components
class ShorebirdUpdateService {
  final ShorebirdUpdater _updater = ShorebirdUpdater();

  Future<bool> checkForUpdates() async {
    try {
      debugPrint('🔄 Verificando atualizações do Shorebird...');
      
      // Verificar se o updater está disponível
      if (!_updater.isAvailable) {
        debugPrint('❌ ShorebirdUpdater não está disponível');
        return false;
      }
      
      // Verificar patch atual
      final currentPatch = await _updater.readCurrentPatch();
      debugPrint('📦 Patch atual: ${currentPatch?.number ?? 'Nenhum'}');
      
      // Verificar se há atualizações
      final status = await _updater.checkForUpdate();
      debugPrint('🔍 Status da verificação: $status');
      
      final hasUpdate = status == UpdateStatus.outdated;
      debugPrint('✅ Tem atualização disponível: $hasUpdate');
      
      return hasUpdate;
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao verificar atualizações: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<void> downloadUpdate() async {
    try {
      debugPrint('⬇️ Iniciando download da atualização...');
      await _updater.update();
      debugPrint('✅ Atualização baixada com sucesso!');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao baixar atualização: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get the current patch number
  Future<String?> getCurrentPatch() async {
    try {
      if (!_updater.isAvailable) return null;
      
      final currentPatch = await _updater.readCurrentPatch();
      return currentPatch?.number.toString();
    } catch (e) {
      debugPrint('❌ Error getting current patch: $e');
      return null;
    }
  }

  /// Check if the updater is available
  bool get isAvailable => _updater.isAvailable;

  Future<void> debugShorebird() async {
    debugPrint('🔧 === DIAGNÓSTICO SHOREBIRD ===');
    
    try {
      debugPrint('📱 ShorebirdUpdater.isAvailable: ${_updater.isAvailable}');
      
      if (_updater.isAvailable) {
        final currentPatch = await _updater.readCurrentPatch();
        debugPrint('📦 Patch atual: ${currentPatch?.number ?? 'Nenhum'}');
        
        final status = await _updater.checkForUpdate();
        debugPrint('🔍 Status da verificação: $status');
        
        switch (status) {
          case UpdateStatus.upToDate:
            debugPrint('✅ App está atualizado');
            break;
          case UpdateStatus.outdated:
            debugPrint('🔄 Atualização disponível');
            break;
          default:
            debugPrint('❓ Status desconhecido - possível problema de conectividade');
            break;
        }
      } else {
        debugPrint('❌ Shorebird não está disponível - possíveis causas:');
        debugPrint('   • App não foi buildado com Shorebird');
        debugPrint('   • Está rodando em debug mode');
        debugPrint('   • Configuração incorreta no shorebird.yaml');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro durante diagnóstico: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    
    debugPrint('🔧 === FIM DO DIAGNÓSTICO ===');
  }
}