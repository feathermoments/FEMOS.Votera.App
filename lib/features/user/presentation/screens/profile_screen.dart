import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/features/user/domain/entities/user_profile_entity.dart';
import 'package:votera_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:votera_app/features/user/presentation/cubit/user_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserCubit()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool _editing = false;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _picCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _picCtrl.dispose();
    super.dispose();
  }

  void _populate(UserProfileEntity p) {
    _nameCtrl.text = p.name;
    _emailCtrl.text = p.email;
    _mobileCtrl.text = p.mobile;
    _picCtrl.text = p.profilePicture;
  }

  void _save(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<UserCubit>().updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      mobileNumber: _mobileCtrl.text.trim(),
      profilePicture: _picCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              if (state is UserLoading || state is UserUpdating) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              if (!_editing) {
                return TextButton(
                  onPressed: () {
                    final profile = context.read<UserCubit>().currentProfile;
                    if (profile != null) _populate(profile);
                    setState(() => _editing = true);
                  },
                  child: const Text('Edit'),
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _editing = false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => _save(context),
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserUpdated) {
            setState(() => _editing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
          if (state is UserError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = (context.read<UserCubit>().currentProfile);
          if (profile == null) {
            return Center(
              child: state is UserError
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (state).message,
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<UserCubit>().loadProfile(),
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── Avatar ──────────────────────────────────────
                  _AvatarSection(
                    profilePictureUrl: _editing
                        ? _picCtrl.text
                        : profile.profilePicture,
                    name: profile.name,
                    editing: _editing,
                    picController: _picCtrl,
                    onPickerTap: () {
                      if (_editing) _showUrlDialog(context);
                    },
                  ),
                  const SizedBox(height: 32),
                  // ── Fields ──────────────────────────────────────
                  _ProfileField(
                    icon: Icons.person_outline_rounded,
                    label: 'Full Name',
                    value: profile.name,
                    controller: _nameCtrl,
                    editing: _editing,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _ProfileField(
                    icon: Icons.phone_outlined,
                    label: 'Mobile',
                    value: profile.mobile,
                    controller: _mobileCtrl,
                    editing: _editing,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _ProfileField(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: profile.email,
                    controller: _emailCtrl,
                    editing: _editing,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (_editing) ...[
                    const SizedBox(height: 16),
                    _ProfileField(
                      icon: Icons.image_outlined,
                      label: 'Profile Picture URL',
                      value: profile.profilePicture,
                      controller: _picCtrl,
                      editing: true,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                  if (_editing) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _save(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showUrlDialog(BuildContext context) {
    final ctrl = TextEditingController(text: _picCtrl.text);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Profile Picture URL'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'https://example.com/photo.jpg',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _picCtrl.text = ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

// ── Avatar Section ─────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.profilePictureUrl,
    required this.name,
    required this.editing,
    required this.picController,
    required this.onPickerTap,
  });

  final String profilePictureUrl;
  final String name;
  final bool editing;
  final TextEditingController picController;
  final VoidCallback onPickerTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'V';
    final hasImage = profilePictureUrl.startsWith('http');

    return Center(
      child: Stack(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasImage ? null : AppColors.blueGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withAlpha(60),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.network(
                      profilePictureUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _Fallback(initial: initial),
                    )
                  : _Fallback(initial: initial),
            ),
          ),
          if (editing)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onPickerTap,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.blueGradient),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Profile Field ──────────────────────────────────────────────────────────────

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.icon,
    required this.label,
    required this.value,
    required this.controller,
    required this.editing,
    this.keyboardType,
    this.validator,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextEditingController controller;
  final bool editing;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    if (!editing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.blue.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.blue, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isNotEmpty ? value : '—',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.blue, size: 20),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
      ),
    );
  }
}
