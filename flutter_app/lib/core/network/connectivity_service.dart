import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides real-time network connectivity status.
///
/// Usage:
///   final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );
});

/// One-shot check — for use outside of widget tree.
Future<bool> isOnline() async {
  final results = await Connectivity().checkConnectivity();
  return !results.contains(ConnectivityResult.none);
}
