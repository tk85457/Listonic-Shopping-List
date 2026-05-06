import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:grocerylist/controllers/auth_controller.dart';
import 'package:grocerylist/core/services/snackbar_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          children: [
            // ── Header card ───────────────────────────────────────
            Obx(() => _ProfileHeader(auth: auth, isDark: isDark, cs: cs)),
            const SizedBox(height: 24),

            // ── Account ──────────────────────────────────────────
            _Section(label: 'Account'),
            _MenuCard(
              children: [
                _Tile(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Info',
                  subtitle: 'Edit your name',
                  onTap: () => _editNameSheet(context, auth),
                ),
                _Divider(),
                _Tile(
                  icon: Icons.photo_library_outlined,
                  title: 'Profile Photo',
                  subtitle: 'Change your picture',
                  onTap: () => _photoSheet(context, auth),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Legal ─────────────────────────────────────────────
            _Section(label: 'Legal'),
            _MenuCard(
              children: [
                _Tile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Policy and permissions',
                  onTap: () => Get.toNamed('/privacy-policy'),
                ),
                _Divider(),
                _Tile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & FAQ',
                  subtitle: 'Get answers and tutorials',
                  onTap: () => Get.toNamed('/faq'),
                ),
                _Divider(),
                _Tile(
                  icon: Icons.email_outlined,
                  title: 'Contact Support',
                  subtitle: 'Email us for help',
                  onTap: () async {
                    final uri = Uri(
                      scheme: 'mailto',
                      path: 'tk8545725@gmail.com',
                      queryParameters: {
                        'subject': 'Listonic - Shopping List Support',
                        'body': 'Describe your issue:\n\n',
                      },
                    );
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Danger Zone ───────────────────────────────────────
            _Section(label: 'Danger Zone'),
            _MenuCard(
              children: [
                _Tile(
                  icon: Icons.restart_alt_rounded,
                  title: 'Reset Profile',
                  subtitle: 'Clear name & photo',
                  iconColor: Colors.redAccent,
                  onTap: () => _confirmReset(context, auth),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheets ───────────────────────────────────────────────────────────

  void _editNameSheet(BuildContext context, AuthController auth) {
    final ctrl = TextEditingController(text: auth.userName.value);

    Get.bottomSheet(
      _Sheet(
        title: 'Edit Name',
        child: Column(
          children: [
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.outfit(),
              decoration: const InputDecoration(
                hintText: 'Your full name',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) return;
                  await auth.updateUserName(name);
                  Get.back();
                  SnackbarService.showSuccess(
                    'Saved',
                    'Name updated successfully',
                  );
                },
                child: Text('Save Changes', style: GoogleFonts.outfit()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _photoSheet(BuildContext context, AuthController auth) {
    final cs = Theme.of(context).colorScheme;

    Get.bottomSheet(
      _Sheet(
        title: 'Profile Photo',
        child: Column(
          children: [
            _SheetOption(
              icon: Icons.camera_alt_rounded,
              label: 'Take Photo',
              color: cs.primary,
              onTap: () {
                Get.back();
                _pick(ImageSource.camera, auth);
              },
            ),
            const SizedBox(height: 8),
            _SheetOption(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              color: cs.primary,
              onTap: () {
                Get.back();
                _pick(ImageSource.gallery, auth);
              },
            ),
            if (auth.userPhoto.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SheetOption(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Photo',
                color: Colors.redAccent,
                onTap: () {
                  Get.back();
                  auth.updateUserPhoto('');
                  SnackbarService.showInfo('Removed', 'Profile photo removed');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource src, AuthController auth) async {
    try {
      final img = await ImagePicker().pickImage(
        source: src,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (img != null) {
        await auth.updateUserPhoto(img.path);
        SnackbarService.showSuccess('Done', 'Profile photo updated');
      }
    } catch (e) {
      SnackbarService.showError('Error', 'Failed to pick photo');
    }
  }

  void _confirmReset(BuildContext context, AuthController auth) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Reset Profile?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Your name and photo will be cleared. Your grocery lists will not be affected.',
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await auth.updateUserName('Guest User');
              await auth.updateUserPhoto('');
              SnackbarService.showInfo('Reset', 'Profile has been reset');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Reset', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Profile Header
// ──────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final AuthController auth;
  final bool isDark;
  final ColorScheme cs;
  const _ProfileHeader({
    required this.auth,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final name = auth.userName.value;
    final photo = auth.userPhoto.value;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: photo.isEmpty
                      ? LinearGradient(
                          colors: [
                            cs.primary,
                            Color.lerp(cs.primary, Colors.purple, 0.5)!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: photo.isNotEmpty
                      ? _photo(photo)
                      : Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.outfit(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              // Camera badge
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 16),

          Text(
            name.isNotEmpty ? name : 'Your Name',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Listonic - Shopping List Member',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photo(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.person, color: Colors.white, size: 50),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.person, color: Colors.white, size: 50),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Bottom sheet wrapper
// ──────────────────────────────────────────────────────────────────────────────

class _Sheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _Sheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2338) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ──────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = iconColor ?? cs.primary;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: iconColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(fontSize: 12, color: cs.onSurfaceVariant),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: cs.onSurfaceVariant,
        size: 20,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: Theme.of(context).dividerColor,
    );
  }
}


