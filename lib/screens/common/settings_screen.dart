import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_router.dart';
import '../../state/app_state.dart';
import '../../models/user_role.dart';
import '../../widgets/navigation/dashboard_tab_back_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _editingProfile = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: AppState().demoProfileName);
    _emailController = TextEditingController(text: AppState().demoProfileEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_profileFormKey.currentState!.validate()) return;
    final updated = AppState().updateDemoProfile(
      name: _nameController.text,
      email: _emailController.text,
    );
    if (!updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile details were not saved. Check the name and email.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _editingProfile = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo profile saved for this app session.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _cancelProfileEdit() {
    _nameController.text = AppState().demoProfileName;
    _emailController.text = AppState().demoProfileEmail;
    setState(() => _editingProfile = false);
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out of the demo?'),
        content: const Text(
          'This returns to the local sign-in screen and clears dashboard navigation. '
          'It does not revoke or change any server-side account access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.loginRoute,
      (route) => false,
    );
  }

  void _switchRoleAndNavigate(BuildContext context, UserRole newRole) {
    AppState().switchRole(newRole);
    final targetRoute = newRole == UserRole.owner
        ? AppRouter.ownerDashboardRoute
        : AppRouter.contractorDashboardRoute;
    Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final state = AppState();
        final currentRole = state.activeRole;

        return Scaffold(
          backgroundColor: AppColors.surfaceWarmGray,
          appBar: AppBar(
            leading: const DashboardTabBackButton(),
            automaticallyImplyLeading: false,
            title: const Text('Settings'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Demo Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    if (!_editingProfile)
                      TextButton.icon(
                        onPressed: () => setState(() => _editingProfile = true),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _editingProfile
                      ? Form(
                          key: _profileFormKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Display name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Enter a display name.'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email address',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  return RegExp(
                                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                      ).hasMatch(email)
                                      ? null
                                      : 'Enter a valid email address.';
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _cancelProfileEdit,
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _saveProfile,
                                      child: const Text('Save'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.demoProfileName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.demoProfileEmail,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Stored locally for this app session only. No account service is connected.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Active Workspace Role',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Frontend demo role switch only. It changes the local workspace, not account security or permissions.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                RadioGroup<UserRole>(
                  groupValue: currentRole,
                  onChanged: (role) {
                    if (role != null) _switchRoleAndNavigate(context, role);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Owner Option Card
                      Card(
                        elevation: currentRole == UserRole.owner ? 3 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: currentRole == UserRole.owner
                                ? AppColors.primaryOrangeForeground
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              _switchRoleAndNavigate(context, UserRole.owner),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.account_balance,
                                    color: AppColors.primaryBlue,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Owner',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Send funds, review expenses, and sign off milestones.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<UserRole>(
                                  value: UserRole.owner,
                                  activeColor:
                                      AppColors.primaryOrangeForeground,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Contractor Option Card
                      Card(
                        elevation: currentRole == UserRole.contractor ? 3 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: currentRole == UserRole.contractor
                                ? AppColors.primaryOrangeForeground
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _switchRoleAndNavigate(
                            context,
                            UserRole.contractor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOrange.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.engineering,
                                    color: AppColors.primaryOrangeForeground,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Contractor',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Confirm receipts, submit expenses, and advance milestone progress.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<UserRole>(
                                  value: UserRole.contractor,
                                  activeColor:
                                      AppColors.primaryOrangeForeground,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.hint,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Current Mode: ${currentRole == UserRole.owner ? "Owner" : "Contractor"}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _confirmSignOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out of Demo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
