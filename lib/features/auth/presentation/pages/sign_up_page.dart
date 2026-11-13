import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/features/auth/presentation/controller/auth_provider.dart';
import 'package:aquanoph/shared/widgets/app_text_field.dart';
import 'package:aquanoph/shared/widgets/gradient_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthProvider>().doSignUp(
          email: _email.text.trim(),
          username: _username.text.trim(),
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        // design: left title Nunito Bold 24 #232323 (Add-Pond wizard header)
        title: const Text('Create account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: AppFonts.heading, color: AppColors.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter your details to get started.',
                  style: TextStyle(fontSize: 16, fontFamily: AppFonts.heading, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Username',
                  hint: 'Your name or farm',
                  controller: _username,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Username is required' : null,
                ),
                const SizedBox(height: 16),
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
                  hint: 'At least 6 characters',
                  controller: _password,
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                ),
                const SizedBox(height: 24),
                GradientButton(label: 'Create account', loading: auth.isLoading, onPressed: _submit),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(auth.error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.danger, fontFamily: AppFonts.body)),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Already have an account? Sign in', style: TextStyle(fontSize: 14, fontFamily: AppFonts.heading, color: AppColors.gradientStart)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
