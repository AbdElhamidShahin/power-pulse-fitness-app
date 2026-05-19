import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/bloc/app_states.dart';

import '../../../shared/bloc/app_cubit.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/number_input_field.dart';

class Idelweight extends StatelessWidget {
  Idelweight({
    super.key,
  });

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = AppCubit.get(context);

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          'الوزن المثالي',
                          style: GoogleFonts.changa(
                              color: Colors.green[100], fontSize: 40),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 50),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: double.infinity,
                          child: Column(
                            children: [
                              NumberInputField(
                                  title: 'الطول',
                                  hintText: 'أدخل طولك',
                                  onChanged: (value) {
                                    cubit.height = double.tryParse(value) ?? 0;
                                  }),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'النوع',
                                      style: GoogleFonts.changa(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.50,
                                          child:
                                              DropdownButtonFormField<String>(
                                            icon: Icon(
                                                Icons.keyboard_arrow_down_sharp,
                                                color: Colors
                                                    .white), // لون أيقونة القائمة
                                            onChanged: (String? value) {
                                              cubit.gender = value!;
                                            },
                                            decoration: InputDecoration(
                                              labelText: "النوع",
                                              labelStyle: TextStyle(
                                                  color: Colors.white),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFC8E6C9),
                                                ), // لون الحواف عند التفعيل
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10), // انحناء الزوايا
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFC8E6C9),
                                                ), // لون الحواف عند التركيز
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10), // انحناء الزوايا
                                              ),
                                            ),
                                            dropdownColor: Colors.green[
                                                100], // لون خلفية القائمة المنسدلة
                                            items: [
                                              DropdownMenuItem(
                                                child: Text(
                                                  "ذكر",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white), // لون النص داخل القائمة
                                                ),
                                                value: "MALE",
                                              ),
                                              DropdownMenuItem(
                                                child: Text(
                                                  "أنثى",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white), // لون النص داخل القائمة
                                                ),
                                                value: "FEMALE",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: PrimaryButton(
                                  text: 'احسب الوزن',
                                  width: double.infinity,
                                  height: 71,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      cubit.Idelweight();
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                                child: Row(
                                  children: [
                                    Text(
                                      'الوزن المثالي  :   ',
                                      style: GoogleFonts.changa(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      cubit.result.toStringAsFixed(2),
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.greenAccent),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 70,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
