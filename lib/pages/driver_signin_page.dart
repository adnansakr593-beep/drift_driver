// ignore_for_file: deprecated_member_use
import 'package:drift_driver/cubits/driver_auth/driver_auth_cubit.dart';
import 'package:drift_driver/cubits/driver_auth/driver_auth_state.dart';
import 'package:drift_driver/helper/const.dart';
import 'package:drift_driver/pages/complete_profile_page.dart';
import 'package:drift_driver/pages/driver_home_page.dart';
import 'package:drift_driver/pages/driver_register_page.dart';
import 'package:drift_driver/widgets/custom_button.dart';
import 'package:drift_driver/widgets/custom_text_form_field.dart';
import 'package:drift_driver/widgets/glass_cont.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});
  static String id = 'driver_signin';

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [
                colors.surface.withOpacity(0.7),
                colors.background,
                colors.surface.withOpacity(0.7),
                colors.background,
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    child: Container(
                      height: 150,
                      width: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        image: const DecorationImage(
                          image: AssetImage(logoPath2),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  Text(
                    'Driver Portal',
                    style: TextStyle(
                      fontSize: 34,
                      fontFamily: fontFamily,
                      color: colors.onBackground,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to start your shift',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: fontFamily,
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Form card
                  BlocConsumer<DriverAuthCubit, DriverAuthState>(
                    listener: (context, state) {
                      if (state is DriverAuthSuccess) {
                        Navigator.pushReplacementNamed(context, HomePage.id);
                      } else if (state is DriverAuthNeedsProfile) {
                        Navigator.pushReplacementNamed(
                            context, CompleteProfilePage.id);
                      } else if (state is DriverAuthFail) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is DriverAuthLoading;

                      return Form(
                        key: _formKey,
                        child: GlassCont(
                          top: BorderSide(
                              color: colors.onBackground.withOpacity(0.4),
                              width: 1.5),
                          bottom: BorderSide(
                              color: colors.onBackground.withOpacity(0.4),
                              width: 1.5),
                          right: BorderSide(
                              color: colors.onBackground.withOpacity(0.4),
                              width: 1.5),
                          left: BorderSide(
                              color: colors.onBackground.withOpacity(0.4),
                              width: 1.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: TextStyle(
                                  color: colors.onBackground.withOpacity(0.8),
                                  fontFamily: fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextFormField(
                                width: double.infinity,
                                hintText: 'driver@example.com',
                                prefixIcon: Icon(Icons.email_outlined,
                                    color: colors.onBackground),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (v) => _email = v,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Email is required'
                                    : null,
                                fillColor: colors.surface,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Password',
                                style: TextStyle(
                                  color: colors.onBackground.withOpacity(0.8),
                                  fontFamily: fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextFormField(
                                width: double.infinity,
                                hintText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline_rounded,
                                    color: colors.onBackground),
                                isPassword: true,
                                onChanged: (v) => _password = v,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Password is required'
                                    : null,
                                fillColor: colors.surface,
                              ),
                              const SizedBox(height: 20),
                              CustomButtom(
                                borderColor: colors.onSurface.withOpacity(0.7),
                                backgroundColor: colors.surface,
                                text: isLoading ? 'Signing in...' : 'Sign In',
                                textColor: colors.onBackground,
                                fontSize: 20,
                                icon: isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.onBackground,
                                        ),
                                      )
                                    : Icon(Icons.login_rounded,
                                        color: colors.onBackground),
                                onTap: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context
                                              .read<DriverAuthCubit>()
                                              .signIn(
                                                email: _email!,
                                                password: _password!,
                                              );
                                        }
                                      },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New driver? ",
                        style: TextStyle(
                          color: colors.onBackground,
                          fontSize: 15,
                          fontFamily: fontFamily,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, DriverRegisterPage.id),
                        child: Text(
                          'Register here',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
