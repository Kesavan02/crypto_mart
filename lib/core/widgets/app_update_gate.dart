import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class AppUpdateGate extends StatefulWidget {
  final Widget child;

  const AppUpdateGate({super.key, required this.child});

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  final _shorebirdUpdater = ShorebirdUpdater();
  Timer? _networkTimer;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _startNetworkListener();
    _checkAndApplyShorebirdUpdate();
  }

  @override
  void dispose() {
    _networkTimer?.cancel();
    super.dispose();
  }

  void _startNetworkListener() {
    _verifyConnection();
    _networkTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _verifyConnection();
    });
  }

  bool _isVerifying = false;

  Future<void> _verifyConnection() async {
    if (_isVerifying) return;
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    _isVerifying = true;
    try {
      if (kIsWeb) {
        if (!_isConnected && mounted) {
          setState(() {
            _isConnected = true;
          });
        }
        return;
      }

      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final hasConnection =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (_isConnected != hasConnection && mounted) {
        setState(() {
          _isConnected = hasConnection;
        });
      }
    } catch (_) {
      if (_isConnected && mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    } finally {
      _isVerifying = false;
    }
  }

  Future<void> _checkAndApplyShorebirdUpdate() async {
    if (kIsWeb) return;
    try {
      if (_shorebirdUpdater.isAvailable) {
        final updateStatus = await _shorebirdUpdater.checkForUpdate();
        if (updateStatus == UpdateStatus.outdated) {
          await _shorebirdUpdater.update();
        }
      }
    } catch (e) {
      debugPrint('Shorebird update check error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: !_isConnected
                    ? _buildOfflineBanner(context)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      key: const ValueKey('offline_banner'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.shade700,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            'No Internet Connection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
