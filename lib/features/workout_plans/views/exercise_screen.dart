import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/exercise.dart';
import '../../../shared/providers/item_provider.dart';
import '../widgets/custom_tab_bar_widget.dart';

class ExerciseScreen extends StatefulWidget {
  final String currentDay;

  ExerciseScreen({Key? key, required this.currentDay}) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showDialog(Exercise exersize) {
    _controller.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor:
              const Color(0xFF212121), // لون خلفية داكن يناسب أجواء الجيم
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Hero Image
                  Container(
                    height: MediaQuery.of(context).size.height * 0.40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(exersize.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    exersize.title,
                    style: GoogleFonts.changa(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .white,
                    ),
                    textAlign: TextAlign.right, // محاذاة النص لليمين
                    textDirection:
                        TextDirection.rtl, // الكتابة من اليمين لليسار
                  ),
                  const SizedBox(height: 10),

                  // Details Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF424242), // لون الخلفية للبطاقة
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      exersize.details,
                      style: GoogleFonts.changa(
                        fontSize: 18,
                        color: Colors.white, // لون النص داخل البطاقة
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right, // محاذاة النص لليمين
                      textDirection:
                          TextDirection.rtl, // الكتابة من اليمين لليسار
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Instructions Section
                  Text(
                    'التعليمات',
                    style: GoogleFonts.changa(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // لون النص الأبيض
                    ),
                    textAlign: TextAlign.right, // محاذاة النص لليمين
                    textDirection:
                        TextDirection.rtl, // الكتابة من اليمين لليسار
                  ),
                  const SizedBox(height: 10),
                  Text(
                    exersize.instructions.join(),
                    style: GoogleFonts.changa(
                      fontSize: 16,
                      color: Colors.grey[300], // لون النص الرمادي الفاتح
                    ),
                    textAlign: TextAlign.right, // محاذاة النص لليمين
                    textDirection:
                        TextDirection.rtl, // الكتابة من اليمين لليسار
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Fixed Button at the Bottom
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, // لون الزر
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'انهاء',
                style: GoogleFonts.changa(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items =
        Provider.of<ItemProvider>(context).getItems(widget.currentDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(' ${widget.currentDay}'),
      ),
      body: Stack(
        children: [
          // صورة الخلفية تظهر عند وجود عناصر
          if (items.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/123456.jpg'), // مسار الصورة الخلفية
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Lottie animation تظهر عند عدم وجود عناصر
          if (items.isEmpty)
            Center(
              child: Lottie.asset(
                'assets/animation/Animation - 1722762361849.json',
              ),
            ),

          // قائمة العناصر
          if (items.isNotEmpty)
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: GestureDetector(
                    onTap: () => _showDialog(item),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white30,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // الصورة
                          Stack(
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                  image: DecorationImage(
                                    image: AssetImage(item.image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // تأثير التعتيم الأبيض الشفاف فوق الصورة
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                  color: Colors.black12,
                                ),
                              ),
                            ],
                          ),
                          // النص
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    item.title,
                                    style: GoogleFonts.changa(
                                      fontSize: 20,
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    item.details,
                                    style: GoogleFonts.changa(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber,
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(8),
                                      ),
                                      child: Icon(Icons.remove),
                                      onPressed: () {
                                        Provider.of<ItemProvider>(context,
                                                listen: false)
                                            .removeItem(
                                                widget.currentDay, item);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomTabBarDemo(pageId: widget.currentDay),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
