import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Abstraction for network connectivity checks.
///
/// Inject this into DataSources / UseCases that need to behave differently
/// when the device is offline (e.g. disable checkout, serve cached data).
abstract class NetworkInfo {
  /// Returns `true` when the device has an active internet connection.
  Future<bool> get isConnected;
}

/// Concrete implementation backed by [InternetConnection]
/// from the `internet_connection_checker_plus` package.
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection _connectionChecker;

  const NetworkInfoImpl(this._connectionChecker);

  @override
  Future<bool> get isConnected => _connectionChecker.hasInternetAccess;
}
