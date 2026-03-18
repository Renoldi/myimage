import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Widget that checks and requests camera, gallery, and internet permissions before showing [child].
class PermissionGate extends StatefulWidget {
  final Widget child;
  final Widget? deniedWidget;

  const PermissionGate({super.key, required this.child, this.deniedWidget});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _granted = false;
  bool _checking = true;

  bool _didRequest = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didRequest) {
      _didRequest = true;
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    List<Permission> perms = [Permission.camera];
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      perms.add(Permission.photos);
    } else {
      perms.add(Permission.storage);
      perms.addAll([Permission.photos, Permission.videos, Permission.audio]);
    }
    bool granted = false;
    try {
      final statuses = await perms.request().timeout(
        const Duration(seconds: 8),
      );
      granted = statuses.values.any((s) => s.isGranted);
    } catch (_) {
      // Timeout or error: fallback to checking current status
      final statuses = await Future.wait(perms.map((p) => p.status));
      granted = statuses.any((s) => s.isGranted);
    }
    setState(() {
      _granted = granted;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_granted) {
      return widget.child;
    }
    return widget.deniedWidget ??
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Permissions are required to use this feature.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPermissions,
                child: const Text('Request Again'),
              ),
            ],
          ),
        );
  }
}
