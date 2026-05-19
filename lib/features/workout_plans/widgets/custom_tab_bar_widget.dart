import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/library.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../exercises/views/muscle_group_add_screen.dart';






class CustomTabBarDemo extends StatelessWidget {
  final String pageId;

  CustomTabBarDemo({Key? key, required this.pageId}) : super(key: key);


  final int pageCount = 6; // عدد الصفحات
  late PageController _controller = PageController(initialPage: 0);
  CustomTabBarController _tabBarController = CustomTabBarController();


  Widget getTabbarChild(BuildContext context, int index) {
    final tabTitles = [
      'صدر',
      'ظهر ',
      'أكتاف',
      'يدين',
      'أرجل',
      'بطن',
    ];
    return TabBarItem(
        transform: ColorsTransform(
            highlightColor: Colors.white,
            normalColor: Colors.white,
            builder: (context, color) {
              return Container(
                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                alignment: Alignment.center,
                constraints: BoxConstraints(minWidth: 100),
                child: Text(
                  tabTitles[index],
                  style: GoogleFonts.changa(
                      fontSize: 18, color: color, fontWeight: FontWeight.bold),
                ),
              );
            }),
        index: index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          CustomTabBar(
            tabBarController: _tabBarController,
            height: 45,
            itemCount: pageCount,
            builder: getTabbarChild,
            indicator: RoundIndicator(
              color: Colors.amber,
              top: 2.5,
              bottom: 2.5,
              left: 2.5,
              right: 2.5,
              radius: BorderRadius.circular(15),
            ),
            pageController: _controller,
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pageCount,
              itemBuilder: (context, index) {
                return PageItem(index, pageId: pageId);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PageItem extends StatelessWidget {
  final int index;
  final String pageId;

  PageItem(this.index, {Key? key, required this.pageId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pages = [
      MuscleGroupAddScreen(pageId: pageId, title: 'تمارين الصدر'),
      MuscleGroupAddScreen(pageId: 'lates', title: 'تمارين الظهر'),
      MuscleGroupAddScreen(pageId: 'shorter', title: 'تمارين الكتف'),
      MuscleGroupAddScreen(pageId: 'hands', title: 'تمارين الذراع'),
      MuscleGroupAddScreen(pageId: 'legs', title: 'تمارين الأرجل'),
      MuscleGroupAddScreen(pageId: 'beily', title: 'تمارين البطن')
    ];
    return pages[index];
  }
}
