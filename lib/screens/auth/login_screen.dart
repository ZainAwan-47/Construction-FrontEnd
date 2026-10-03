import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_router.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../state/app_state.dart';
import '../../models/user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'ahmad@email.com');
  final _passwordController = TextEditingController(text: '12345678');

  void _handleMockLogin() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logging in...', style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // FIXED: Dynamic routing based on the active role in AppState
      String destination = AppState().activeRole == UserRole.contractor 
          ? AppRouter.contractorDashboardRoute 
          : AppRouter.ownerDashboardRoute;

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pushReplacementNamed(context, destination);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 48, 32, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Hello!', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1.0)),
                  SizedBox(height: 8),
                  Text('Welcome to Construction App', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceWarmGray,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Sign In', style: TextStyle(color: AppColors.primaryBlue, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 32),
                        AuthTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
                        ),
                        AuthTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _handleMockLogin,
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Expanded(child: Divider(color: Colors.black12)),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Or login with', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500))),
                            Expanded(child: Divider(color: Colors.black12)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialButton(icon: Icons.facebook, color: const Color(0xFF1877F2), onPressed: () {}),
                            const SizedBox(width: 20),
                            _SocialButton(icon: Icons.g_mobiledata, color: const Color(0xFFDB4437), onPressed: () {}),
                            const SizedBox(width: 20),
                            _SocialButton(icon: Icons.apple, color: Colors.black, onPressed: () {}),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRouter.signupRoute),
                              child: const Text('Sign Up', style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _SocialButton({required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}