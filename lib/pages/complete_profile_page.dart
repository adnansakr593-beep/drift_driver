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

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});
  static String id = 'complete_profile';

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _phone, _vehicleModel, _vehiclePlate;

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
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surface,
                      ),
                      child: Icon(Icons.directions_car_rounded,
                          size: 55, color: colors.onSurface),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 26,
                      fontFamily: fontFamily,
                      color: colors.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Add your vehicle details to start accepting rides',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: fontFamily,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
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
                              const SizedBox(height: 14),
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
                              const SizedBox(height: 14),
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
                                text:
                                    isLoading ? 'Saving...' : 'Save & Continue',
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
                                    : Icon(Icons.arrow_forward_rounded,
                                        color: colors.onBackground),
                                onTap: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context
                                              .read<DriverAuthCubit>()
                                              .completeProfile(
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
