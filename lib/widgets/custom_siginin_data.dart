
import 'package:drift_driver/cubits/driver_auth/driver_auth_cubit.dart';
import 'package:drift_driver/cubits/driver_auth/driver_auth_state.dart';
import 'package:drift_driver/helper/const.dart';
import 'package:drift_driver/pages/driver_home_page.dart';
import 'package:drift_driver/pages/forgot_pass_page.dart';
import 'package:drift_driver/widgets/custom_button.dart';
import 'package:drift_driver/widgets/custom_text_form_field.dart';
import 'package:drift_driver/widgets/glass_cont.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class CustomSigininData extends StatefulWidget {
  const CustomSigininData({
    super.key,
  });

  @override
  State<CustomSigininData> createState() => _CustomSigininDataState();
}

class _CustomSigininDataState extends State<CustomSigininData> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Form(
      key: formKey,
      child: GlassCont(
        backgroundColor: colors.background.withOpacity(0.7),
        width: 300,
        border: Border.all(
          color: colors.onBackground.withOpacity(0.4),
          width: 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                'Email',
                style: TextStyle(
                  color: colors.onBackground.withOpacity(0.8),
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: CustomTextFormField(
                hintText: 'name@example.com',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: colors.onBackground,
                ),
                onChanged: (value) => email = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Invalid email format';
                  }
                  return null;
                },
                fillColor: colors.surface,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 8),
              child: Text(
                'Password',
                style: TextStyle(
                  color: colors.onBackground.withOpacity(0.8),
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: CustomTextFormField(
                hintText: 'Password',
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: colors.onBackground,
                ),
                isPassword: true,
                onChanged: (value) => password = value,
                validator: (value) =>
                    value!.isEmpty ? 'Password is required' : null,
                fillColor: colors.surface,
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ForgotPassPage.id);
                  },
                  child: Text(
                    'Forgot Password ?',
                    style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 14,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            BlocConsumer<DriverAuthCubit, DriverAuthState>(
              listener: (context, state) {
                if (state is DriverAuthSuccess) {
                  Navigator.pushNamed(context, HomePage.id);
                } else if (state is DriverAuthFail) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is DriverAuthLoading;
                return CustomButtom(
                  borderColor: colors.onSurface.withOpacity(0.7),
                  backgroundColor: colors.surface,
                  text: isLoading ? 'Loading...' : 'Sign in',
                  textColor: colors.onBackground,
                  onTap: isLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            context.read<DriverAuthCubit>().signIn(
                                  email: email!,
                                  password: password!,
                                );
                          }
                        },
                  icon: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onBackground,
                          ),
                        )
                      : Icon(
                          Icons.login_rounded,
                          color: colors.onBackground,
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
