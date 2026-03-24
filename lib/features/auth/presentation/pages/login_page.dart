import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Form key lets us validate all fields at once
  final _formKey = GlobalKey<FormState>();

  // Controllers read the text the user typed
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Tracks whether the password eye icon is showing/hiding
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Called when user taps the "Continue" button.
  void _onContinueTapped() {
    // Validate all fields — if any fail, form shows error messages
    if (_formKey.currentState?.validate() ?? false) {
      // Dispatch the event to AuthBloc — BLoC handles the Firebase call
      context.read<AuthBloc>().add(
            SignInWithEmailRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // BlocListener listens for state changes WITHOUT rebuilding the UI.
      // Use it for side-effects: navigation, snackbars, dialogs.
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate to home and remove login from the back-stack
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (state is AuthFailureState) {
            // Show a red snackbar with the Firebase error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        // BlocBuilder rebuilds the UI whenever state changes.
        // We use it here only to show/hide the loading spinner on the button.
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // ── App logo / name ──────────────────────────
                    _buildAppLogo(),

                    const SizedBox(height: 40),

                    // ── Login card ───────────────────────────────
                    _buildLoginCard(isLoading),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Widgets broken into small methods for readability ─────

  /// Bus icon + "Move Smart" text — matches the Figma "Start" screen branding
  Widget _buildAppLogo() {
    return Column(
      children: [
        // Bus icon container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_bus_rounded,
            size: 56,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// The white card containing the entire login form
  Widget _buildLoginCard(bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──────────────────────────────────
            const Text(
              AppStrings.login,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter your email to sign up for this app',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 24),

            // ── Email field ────────────────────────────
            _buildEmailField(),
            const SizedBox(height: 16),

            // ── Password field ─────────────────────────
            _buildPasswordField(),
            const SizedBox(height: 8),

            // ── Forgot password link ───────────────────
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to forgot password screen
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  AppStrings.forgotPassword,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Continue button ────────────────────────
            _buildContinueButton(isLoading),
            const SizedBox(height: 20),

            // ── Divider with "or" ──────────────────────
            _buildDivider(),
            const SizedBox(height: 20),

            // ── Social login buttons ───────────────────
            SocialLoginButton(
              label: AppStrings.continueGoogle,
              iconAsset: 'google', // uses Icons fallback inside widget
              onPressed: isLoading
                  ? null
                  : () => context.read<AuthBloc>().add(
                        SignInWithGoogleRequested(),
                      ),
            ),
            const SizedBox(height: 12),
            SocialLoginButton(
              label: AppStrings.continueApple,
              iconAsset: 'apple',
              onPressed: isLoading
                  ? null
                  : () => context.read<AuthBloc>().add(
                        SignInWithAppleRequested(),
                      ),
            ),
            const SizedBox(height: 24),

            // ── Create account link ────────────────────
            _buildSignUpLink(),
          ],
        ),
      ),
    );
  }

  /// Email text field with validation
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      // Prevents autocorrect from changing email addresses
      autocorrect: false,
      validator: Validators.email,
      decoration: InputDecoration(
        hintText: AppStrings.email,
        filled: true,
        fillColor: AppColors.background,
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  /// Password text field with show/hide toggle
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      // obscureText hides characters — toggled by the eye icon
      obscureText: _obscurePassword,
      validator: Validators.password,
      decoration: InputDecoration(
        hintText: AppStrings.password,
        filled: true,
        fillColor: AppColors.background,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textGrey),
        // Eye icon to show/hide password
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textGrey,
          ),
          onPressed: () {
            // setState here is fine — it only affects this one icon
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  /// "Continue" button — shows spinner when BLoC is loading
  Widget _buildContinueButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: isLoading ? null : _onContinueTapped,
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Continue',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Horizontal line with "or" in the middle
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  /// "Don't have an account? Create an account" link
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          AppStrings.noAccount,
          style: TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.signUp);
          },
          child: const Text(
            'Create an account',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
