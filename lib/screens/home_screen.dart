import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:cash_admin/main.dart';
import 'package:cash_admin/screens/agent/add_agent_screen.dart';
import 'package:cash_admin/screens/customer/add_cutsomer_screen.dart';
import 'package:cash_admin/screens/add_payments.dart';
import 'package:cash_admin/screens/agent/all_agents.dart';
import 'package:cash_admin/screens/customer/all_customers.dart';
import 'package:cash_admin/screens/daily_payments_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final notchBottomBarController = NotchBottomBarController(index: 1);
  int _currentIndex = 0;
  final EasyInfiniteDateTimelineController _controller = EasyInfiniteDateTimelineController();
  DateTime _focusDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFD8DCF7).withOpacity(0.25),
            const Color(0xFFC5CEF9),
          ],
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _items("Add \n Customer", const AddCustomerPage(), FontAwesomeIcons.userPlus),
                  _items("All\n Customers", const AllCustomerScreen(), FontAwesomeIcons.list),
                  // _items("Daily\n Payments", AddCustomerPage(), FontAwesomeIcons.globe),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _items("Add\nAgent", const AddAgentScreen(), FontAwesomeIcons.personCirclePlus),
                  _items("All\nAgents", const AllAgents(), FontAwesomeIcons.addressBook),
                  // _items("", AddCustomerPage(), FontAwesomeIcons.userPlus),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     _items("", AddCustomerPage()),
              //     _items("", AddCustomerPage()),
              //     _items("", AddCustomerPage()),
              //   ],
              // ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: ClipPath(
              clipper: MyCustomClipper(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFF2D355C),
                      Color(0xFF24274A),
                    ],
                  ),
                ),
                child: EasyInfiniteDateTimeLine(
                  controller: _controller,
                  // timeLineProps: EasyTimeLineProps(),
                  // dayProps: EasyDayProps(),
                  dayProps: EasyDayProps(
                    dayStructure: DayStructure.monthDayNumDayStr,
                    // dayStructure: DayStructure.dayNumDayStr,
                    width: 50,
                    height: MediaQuery.of(context).size.height * 0.42,
                    // activeBorderRadius: ,
                    todayStyle: DayStyle(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFA5A6E5),
                          ),
                          BoxShadow(
                            color: Color(0xff000000),
                          )
                        ],
                        // color: Colors.orange,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xff272B50),
                            Color(0xff5152A4),
                          ],
                        ),
                      ),
                    ),
                    inactiveDayStyle: const DayStyle(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFA5A6E5),
                          ),
                          BoxShadow(
                            color: Color(0xff000000),
                          )
                        ],
                        // color: Colors.orange,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xff272B50),
                            Color(0xff5152A4),
                          ],
                        ),
                      ),
                    ),
                    activeDayStyle: const DayStyle(
                      // dayNumStyle: TextStyle(color: Colors.black, fontSize: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xff3371FF),
                            Color(0xff8426D6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  firstDate: DateTime(DateTime.now().year, DateTime.now().month),
                  focusDate: _focusDate,
                  lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                  onDateChange: (selectedDate) {
                    setState(() {
                      _focusDate = selectedDate;
                      logger.i(selectedDate);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DailyPaymentsScreen(
                                    selectedDate: selectedDate,
                                  )));
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _items(String text, Widget widget, IconData icon) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => widget));
          },
          child: Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              // color: Color(0xFFD6DBEE),
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6F8CB0).withOpacity(0.25),
                  blurRadius: 16.0,
                ),
              ],
              gradient: const LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFFD6E3F3),
                  Color(0xFFFFFFFF),
                ],
              ),
            ),
            child: Center(
              child: FaIcon(icon),
            ),
          ),
        ),
        SizedBox(
          height: 6,
        ),
        Text(
          text,
          style: TextStyle(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // var controlPoint1 = Offset(50, size.height - 100);
    // var controlPoint2 = Offset(size.width - 50, size.height);
    // var endPoint = Offset(size.width, size.height - 50);
    var controlPoint1 = Offset(200, 180);
    var controlPoint2 = Offset(size.width - 180, -20);
    var endPoint = Offset(size.width, 120);
    // var endPoint = Offset(, dy)
    Path path = Path()
      // ..moveTo(0, size.height)
      ..moveTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, 50)
      // ..lineTo(0, size.height) // Add line p1p2
      // ..lineTo(size.width, size.height) // Add line p2p3
      // ..lineTo(size.width, 0)
      ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, endPoint.dx, endPoint.dy)
      ..close();

    // Path path = Path()
    //   // ..lineTo(0, size.height)
    //   // ..lineTo(size.width, size.height)
    //   // ..close();
    //   //
    //   //
    //   ..moveTo(size.width / 2, 0) // move path point to (w/2,0)
    //   ..lineTo(0, size.width)
    //   ..lineTo(size.width, size.height)
    //   ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
