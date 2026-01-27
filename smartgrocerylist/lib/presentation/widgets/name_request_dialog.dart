import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartgrocerylist/controllers/auth_controller.dart';

class NameRequestDialog extends StatefulWidget {
  const NameRequestDialog({super.key});

  @override
  State<NameRequestDialog> createState() => _NameRequestDialogState();
}

class _NameRequestDialogState extends State<NameRequestDialog> {
  final TextEditingController _nameController = TextEditingController();
  final AuthController _authController = Get.find();
  bool _isLoading = false;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter your name', backgroundColor: Colors.red.shade100);
      return;
    }

    // Zero Latency: Close immediately
    Get.back();
    Get.snackbar('Welcome!', 'Profile updated successfully', backgroundColor: Colors.green.shade100);

    // Background tasks
    Future(() async {
      await Permission.notification.request();
      await _authController.updateUserName(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false, // Force user to provide name or skip
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Complete Your Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your name to personalize your experience.'),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            Text(
              'We\'ll also ask for notification permission to keep your lists synced.',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Skip', style: TextStyle(color: Colors.grey.shade600)),
            ),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.8), // Darker shade
              foregroundColor: colorScheme.onPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save & Continue'),
          ),
        ],
      ),
    );
  }
}
