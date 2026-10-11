import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../constants/AppConstants.dart';

class SignalRService {
  HubConnection? _hubConnection;

  // You can expose streams or callbacks for different events
  final List<Function(String)> _expiryAlertListeners = [];
  final List<Function(String)> _lowStockWarningListeners = [];

  Future<void> init() async {
    final serverUrl = "${AppConstants.baseUrl}/hubs/inventory"; // e.g., http://localhost:5000/hubs/inventory

    _hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl)
        .withAutomaticReconnect()
        .build();

    _hubConnection?.onclose(({Exception? error}) {
      debugPrint("SignalR Connection Closed: $error");
    });

    _hubConnection?.on("ReceiveExpiryAlert", _handleExpiryAlert);
    _hubConnection?.on("ReceiveLowStockWarning", _handleLowStockWarning);

    try {
      await _hubConnection?.start();
      debugPrint("SignalR Connected Successfully!");
    } catch (e) {
      debugPrint("SignalR Connection Error: $e");
    }
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
}

// Singleton instance
final signalRService = SignalRService();
