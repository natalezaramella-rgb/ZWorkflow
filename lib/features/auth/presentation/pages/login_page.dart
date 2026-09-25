import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../../../../app/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';

/// Login page with email/password and Google Sign-In.
class LoginPage extends StatefulWidget {
  /// Creates a [LoginPage].
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthSignInWithEmailRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  void _onGoogleSignIn() {
    context.read<AuthBloc>().add(const AuthSignInWithGoogleRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          messenger?.showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: defaultTargetPlatform == TargetPlatform.iOS
          ? _buildCupertino(l10n)
          : _buildMaterial(l10n),
    );
  }

  Widget _buildMaterial(AppLocalizations l10n) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Title
                  Icon(
                    Icons.work_outline_rounded,
                    size: 72,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.welcomeBack,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: l10n.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _onSignIn(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign in button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onSignIn,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.loginWithEmail),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'oppure',
                          style: TextStyle(color: AppColors.textSecondaryLight),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign-In
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _onGoogleSignIn,
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: Text(l10n.loginWithGoogle),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register link
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(l10n.noAccount),
                      TextButton(
                        onPressed: () {
                          // Navigate to register page
                        },
                        child: Text(l10n.register),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCupertino(AppLocalizations l10n) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.briefcase,
                    size: 72,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.appTitle,
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .navLargeTitleTextStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.welcomeBack,
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .copyWith(color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 40),

                  // Email field
                  CupertinoTextField(
                    controller: _emailController,
                    placeholder: l10n.email,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(CupertinoIcons.mail,
                          color: CupertinoColors.systemGrey),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: CupertinoColors.systemGrey4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CupertinoTextField(
                    controller: _passwordController,
                    placeholder: l10n.password,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(CupertinoIcons.lock,
                          color: CupertinoColors.systemGrey),
                    ),
                    obscureText: _obscurePassword,
                    suffix: CupertinoButton(
                      padding: const EdgeInsets.only(right: 10),
                      minimumSize: Size.zero,
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                        color: CupertinoColors.systemGrey,
                        size: 20,
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: CupertinoColors.systemGrey4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign in button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          onPressed: isLoading ? null : _onSignIn,
                          child: isLoading
                              ? const CupertinoActivityIndicator(
                                  color: CupertinoColors.white)
                              : Text(l10n.loginWithEmail),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Google Sign-In
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: _onGoogleSignIn,
                      color: CupertinoColors.systemGrey6,
                      child: Text(
                        l10n.loginWithGoogle,
                        style: const TextStyle(
                            color: CupertinoColors.label),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register link
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(l10n.noAccount),
                      CupertinoButton(
                        padding: const EdgeInsets.only(left: 4),
                        onPressed: () {
                          // Navigate to register page
                        },
                        child: Text(l10n.register),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
