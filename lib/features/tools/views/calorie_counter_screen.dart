import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/bloc/app_cubit.dart';
import '../../../shared/bloc/app_states.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/number_input_field.dart';

class Culcolatecounting extends StatefulWidget {
  const Culcolatecounting({super.key});

  @override
  State<Culcolatecounting> createState() => _CulcolatecountingState();
}

class _CulcolatecountingState extends State<Culcolatecounting> {


  GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>AppCubit(),
      child: BlocConsumer<AppCubit,AppState>(
        builder: (BuildContext context, AppState state) {
          var cubit =AppCubit.get(context);
          return   Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(backgroundColor: Colors.white60,
              body: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'حساب السعرات الحرارية',
                          style: GoogleFonts.changa(
                              color: Colors.green[100], fontSize: 28),
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: double.infinity,
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              NumberInputField(
                                hintText: 'أدخل طولك (سم)',
                                title: 'الطول',
                                onChanged: (value) => setState(() {
                                  cubit.height0 = double.tryParse(value) ?? 0;
                                }),
                              ),
                              NumberInputField(
                                hintText: 'أدخل عمرك',
                                title: 'العمر  ',
                                onChanged: (value) => setState(() {
                                  cubit.age = double.tryParse(value) ?? 0;
                                }),
                              ),
                              NumberInputField(
                                hintText: 'أدخل وزنك (كجم)',
                                title: 'الوزن  ',
                                onChanged: (value) => setState(() {
                                  cubit.weight = double.tryParse(value) ?? 0;
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'النوع  ',
                                      style: GoogleFonts.changa(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.50,
                                      child: DropdownButtonFormField(
                                        icon: Icon(Icons.keyboard_arrow_down_sharp),
                                        onChanged: (String? value) {
                                          setState(() {
                                            cubit.gender0 = value!;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "النوع",
                                          labelStyle: TextStyle(color: Colors.white),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color(0xFFC8E6C9),
                                            ), // لون الحواف عند التفعيل
                                            borderRadius: BorderRadius.circular(
                                                10), // انحناء الزوايا
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFC8E6C9),
                                            ), // لون الحواف عند التركيز
                                            borderRadius: BorderRadius.circular(
                                                10), // انحناء الزوايا
                                          ),
                                        ),
                                        dropdownColor: Colors
                                            .green[100], // لون خلفية القائمة المنسدلة

                                        items: const [
                                          DropdownMenuItem(
                                            child: Text("ذكر"),
                                            value: "MALE",
                                          ),
                                          DropdownMenuItem(
                                            child: Text("أنثى"),
                                            value: "FEMALE",
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      ' النشاط  ',
                                      style: GoogleFonts.changa(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.50,
                                      child: DropdownButtonFormField(
                                        icon: Icon(Icons.keyboard_arrow_down_sharp),
                                        onChanged: (String? value) {
                                          setState(() {
                                            cubit.activityLevel = value!;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: " النشاط",
                                          labelStyle: TextStyle(color: Colors.white),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFC8E6C9),
                                            ), // لون الحواف عند التفعيل
                                            borderRadius: BorderRadius.circular(
                                                10), // انحناء الزوايا
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFC8E6C9),
                                            ), // لون الحواف عند التركيز
                                            borderRadius: BorderRadius.circular(
                                                10), // انحناء الزوايا
                                          ),
                                        ),
                                        dropdownColor: Colors
                                            .green[100], // لون خلفية القائمة المنسدلة

                                        items: const [
                                          DropdownMenuItem(
                                            child: Text("قليل النشاط"),
                                            value: "culc1",
                                          ),
                                          DropdownMenuItem(
                                            child: Text("نشاط خفيف"),
                                            value: "culc2",
                                          ),
                                          DropdownMenuItem(
                                            child: Text("نشاط معتدل"),
                                            value: "culc3",
                                          ),
                                          DropdownMenuItem(
                                            child: Text("نشاط كبير"),
                                            value: "culc4",
                                          ),
                                          DropdownMenuItem(
                                            child: Text("نشاط شديد"),
                                            value: "culc5",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: PrimaryButton(
                                  text: 'احسب السعرات الحرارية',
                                  width: double.infinity,
                                  height: 71,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      cubit.calculateFinalResult(); // استدعاء الطريقة بشكل صحيح
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'الوزن المثالي : ',
                              style: GoogleFonts.changa(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              cubit.finalResult.toStringAsFixed(2),
                              style:
                              TextStyle(fontSize: 20, color: Colors.greenAccent),
                            ),
                          ],
                        ),
                      ),
                      if (cubit.showCalorieTexts) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            style:
                            TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                            '- انت تحتاج إلى ${(cubit.finalResult - cubit.B).toStringAsFixed(0)} سعرات حراريه يومياً لانقاص 0.5 كجم كل اسبوع',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            style:
                            TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                            '- انت تحتاج إلى ${(cubit.finalResult - cubit.A).toStringAsFixed(0)} سعرات حراريه يومياً لانقاص 1.0 كجم كل اسبوع',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            style:
                            TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                            '-  انت تحتاج إلى ${(cubit.B + cubit.finalResult).toStringAsFixed(0)} سعرات حراريه يومياً لزياده 0.5 كجم كل اسبوع',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            style:
                            TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                            '-  انت تحتاج إلى ${(cubit.A + cubit.finalResult).toStringAsFixed(0)} سعرات حراريه يومياً لزياده 1.0 كجم كل اسبوع',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        listener: (BuildContext context, AppState state) {  },
      ),
    );
  }
}