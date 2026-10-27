import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../constants/AppConstants.dart';

class SignalRService {
  HubConnection? _hubConnection;

  // You can expose streams or callbacks for different events
  final List<Function(String)> _expiryAlertListeners = [];
  final List<Function(String)> _lowStockWarningListeners = [];
  final List<Function(String)> _stockImportUpdateListeners = [];

  /// Kết nối hub kèm JWT (hub yêu cầu đăng nhập). Gọi sau khi đăng nhập thành công.
  Future<void> init({required String token}) async {
    await stop();
    final serverUrl = "${AppConstants.baseUrl}/hubs/inventory"; // e.g., http://localhost:5000/hubs/inventory

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          serverUrl,
          options: HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection?.onclose(({Exception? error}) {
      debugPrint("SignalR Connection Closed: $error");
    });

    _hubConnection?.on("ReceiveExpiryAlert", _handleExpiryAlert);
    _hubConnection?.on("ReceiveLowStockWarning", _handleLowStockWarning);
    _hubConnection?.on("ReceiveStockImportUpdate", _handleStockImportUpdate);

    try {
      await _hubConnection?.start();
      debugPrint("SignalR Connected Successfully!");
    } catch (e) {
      debugPrint("SignalR Connection Error: $e");
    }
  }

  /// Ngắt kết nối (khi đăng xuất / hết phiên).
  Future<void> stop() async {
    final conn = _hubConnection;
    _hubConnection = null;
    try {
      await conn?.stop();
    } catch (_) {}
  }

  void _handleExpiryAlert(List<Object?>? parameters) {
    if (parameters != null && parameters.isNotEmpty) {
      final message = parameters.first.toString();
      debugPrint("Received Expiry Alert: $message");
      for (var listener in _expiryAlertListeners) {
        listener(message);
      }
    }
  }

  void _handleLowStockWarning(List<Object?>? parameters) {
    if (parameters != null && parameters.isNotEmpty) {
      final message = parameters.first.toString();
      debugPrint("Received Low Stock Warning: $message");
      for (var listener in _lowStockWarningListeners) {
        listener(message);
      }
    }
  }

  void _handleStockImportUpdate(List<Object?>? parameters) {
    final message = (parameters != null && parameters.isNotEmpty) 
        ? parameters.first.toString() 
        : "Phiếu nhập kho đã được cập nhật";
    debugPrint("Received Stock Import Update: $message");
    for (var listener in _stockImportUpdateListeners) {
      listener(message);
    }
  }

  void onExpiryAlert(Function(String) callback) {
    _expiryAlertListeners.add(callback);
  }

  void removeExpiryAlertListener(Function(String) callback) {
    _expiryAlertListeners.remove(callback);
  }

  void onLowStockWarning(Function(String) callback) {
    _lowStockWarningListeners.add(callback);
  }

  void removeLowStockWarningListener(Function(String) callback) {
    _lowStockWarningListeners.remove(callback);
  }

  void onStockImportUpdate(Function(String) callback) {
    _stockImportUpdateListeners.add(callback);
  }

  void removeStockImportUpdateListener(Function(String) callback) {
    _stockImportUpdateListeners.remove(callback);
  }
}

// Singleton instance
final signalRService = SignalRService();
