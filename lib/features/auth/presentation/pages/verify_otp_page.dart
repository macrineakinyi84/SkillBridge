import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/backend_session.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/backend_auth_api.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart' as router;
import '../../../../features/auth/domain/entities/user_role.dart';
import '../../../../shared/widgets/auth_scope.dart';

/// S-006: OTP Verification. 6-digit OTP within 10 minutes (FR-002).
class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key, this.email, this.otp});

  final String? email;
  /// When present (e.g. from backend in dev), pre-fill and show so user can verify without email.
  final String? otp;

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    if (widget.otp != null && widget.otp!.length == 6) {
      _otpController.text = widget.otp!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dev: Your code is ${widget.otp}')),
        );
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final email = widget.email?.trim() ?? '';
    final otp = _otpController.text.trim();
    if (email.isEmpty) {
      setState(() => _message = 'Missing email. Please go back and try again.');
      return;
    }
    if (otp.length != 6) {
      setState(() => _message = 'OTP must be 6 digits.');
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final res = await BackendAuthApi.verifyOtp(email: email, otp: otp);
      await sl<BackendSession>().setToken(res.token);

      // Parse user with role from response/JWT (role persisted in token in secure storage).
      final claims = sl<BackendSession>().state.claims;
      final user = UserEntity.fromBackendClaims({
        ...claims,
        if (res.user['email'] != null) 'email': res.user['email'],
        if (res.user['role'] != null) 'role': res.user['role'],
      });
      AuthScope.of(context).setAuthenticated(user);

      if (!mounted) return;
      if (user.role == UserRole.employer) {
        context.go(router.AppRouter.employerDashboard);
      } else {
        context.go(router.AppRouter.dashboard);
      }
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final email = widget.email?.trim() ?? '';
    if (email.isEmpty) {
      setState(() => _message = 'Missing email. Please go back and try again.');
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final otp = await BackendAuthApi.requestOtp(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(otp != null ? 'Dev: Your code is $otp' : 'Code resent. Check your email.'),
        ),
      );
      if (otp != null && mounted) {
        setState(() => _otpController.text = otp);
      }
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Verify email'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.go(router.AppRouter.login)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Enter the 6-digit code sent to ${widget.email ?? 'your email'}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(labelText: 'OTP code', hintText: '000000'),
              ),
              if (_message != null) ...[
                const SizedBox(height: 8),
                Text(_message!, style: TextStyle(color: AppColors.error, fontSize: 14)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify'),
              ),
              TextButton(
                onPressed: _loading ? null : _resend,
                child: const Text('Resend code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
