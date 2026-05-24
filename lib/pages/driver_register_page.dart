// ignore_for_file: deprecated_member_use
import 'package:drift_driver/cubits/driver_auth/driver_auth_cubit.dart';
import 'package:drift_driver/cubits/driver_auth/driver_auth_state.dart';
import 'package:drift_driver/helper/const.dart';
import 'package:drift_driver/pages/driver_home_page.dart';
import 'package:drift_driver/widgets/custom_button.dart';
import 'package:drift_driver/widgets/custom_text_form_field.dart';
import 'package:drift_driver/widgets/glass_cont.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverRegisterPage extends StatefulWidget {
  const DriverRegisterPage({super.key});
  static String id = 'driver_register';

  @override
  State<DriverRegisterPage> createState() => _DriverRegisterPageState();
}

class _DriverRegisterPageState extends State<DriverRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name, _email, _password, _phone, _vehicleModel, _vehiclePlate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
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
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios_new,
                              color: colors.onSurface, size: 28),
                        ),
                        Text(
                          'Driver Registration',
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: fontFamily,
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  BlocConsumer<DriverAuthCubit, DriverAuthState>(
                    listener: (context, state) {
                      if (state is DriverAuthSuccess) {
                        Navigator.pushReplacementNamed(context, HomePage.id);
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
                              _label('Full Name', colors),
                              CustomTextFormField(
                                width: double.infinity,
                                hintText: 'Mohamed Ahmed',
                                prefixIcon: Icon(Icons.person_outline,
                                    color: colors.onBackground),
                                onChanged: (v) => _name = v,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Name is required'
                                    : null,
                                fillColor: colors.surface,
                              ),
                              const SizedBox(height: 12),
                              _label('Email', colors),
                              CustomTextFormField(
                                width: double.infinity,
                                hintText: 'driver@example.com',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icon(Icons.email_outlined,
                                    color: colors.onBackground),
                                onChanged: (v) => _email = v,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Email is required'
                                    : null,
                                fillColor: colors.surface,
                              ),
                              const SizedBox(height: 12),
                              _label('Password', colors),
                              CustomTextFormField(
                                width: double.infinity,
                                hintText: 'Min 6 characters',
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: colors.onBackground),
                                isPassword: true,
                                onChanged: (v) => _password = v,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 6) {
                                    return 'At least 6 characters';
                                  }
                                  return null;
                                },
                                fillColor: colors.surface,
                              ),
                              const SizedBox(height: 12),
                              _label('Phone Number', colors),
                              CustomTextFormField(
                                width: double.infinity,
                                hintText: '+20 1XX XXX XXXX',
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icon(Icons.phone_outlined,
                                    color: colors.onBackground),
                                onChanged: (v) => _phone = v,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Phone is required'
                                    : null,
                                fillColor: colors.surface,
                              ),
                              const SizedBox(height: 12),
                              _label('Vehicle Model', colors),
                              CustomTextFormField(
                                width: double.infinity,
                                hintText: 'Toyota Corolla 2022',
                                prefixIcon: Icon(Icons.directions_car_outlined,
                                    color: colors.onBackground),
                                onChanged: (v) => _vehicleModel = v,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Vehicle model is required'
                                    : null,
                                fillColor: colors.surface,
                              ),
                              const SizedBox(height: 12),
                              _label('Vehicle Plate', colors),
                              CustomTextFormField(
                                width: double.infinity,
                                hintText: 'ABC 1234',
                                prefixIcon: Icon(
                                    Icons.confirmation_number_outlined,
                                    color: colors.onBackground),
                                onChanged: (v) => _vehiclePlate = v,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Plate number is required'
                                    : null,
                                fillColor: colors.surface,
                              ),
                              const SizedBox(height: 20),
                              CustomButtom(
                                borderColor: colors.onSurface.withOpacity(0.7),
                                backgroundColor: colors.surface,
                                text: isLoading
                                    ? 'Registering...'
                                    : 'Create Account',
                                textColor: colors.onBackground,
                                fontSize: 18,
                                icon: isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.onBackground,
                                        ),
                                      )
                                    : Icon(Icons.how_to_reg_rounded,
                                        color: colors.onBackground),
                                onTap: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context
                                              .read<DriverAuthCubit>()
                                              .register(
                                                email: _email!,
                                                password: _password!,
                                                name: _name!,
                                                phone: _phone!,
                                                vehicleModel: _vehicleModel!,
                                                vehiclePlate: _vehiclePlate!,
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
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: colors.onBackground.withOpacity(0.8),
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
