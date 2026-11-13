import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/features/auth/presentation/controller/auth_provider.dart';
import 'package:aquanoph/features/auth/presentation/pages/sign_up_page.dart';
import 'package:aquanoph/shared/widgets/app_text_field.dart';
import 'package:aquanoph/shared/widgets/gradient_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthProvider>().doSignIn(email: _email.text.trim(), password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const Text(
                  'Aquanoph',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: AppFonts.heading, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your pond',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontFamily: AppFonts.heading, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 40),
                AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _password,
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                ),
                const SizedBox(height: 24),
                GradientButton(label: 'Sign in', loading: auth.isLoading, onPressed: _submit),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(auth.error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.danger, fontFamily: AppFonts.body)),
                  ),
                if (auth.info != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(auth.info!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontFamily: AppFonts.body)),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpPage())),
                  child: const Text('New here? Create an account', style: TextStyle(fontSize: 14, fontFamily: AppFonts.heading, color: AppColors.gradientStart)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
