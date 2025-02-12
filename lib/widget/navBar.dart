import 'package:flutter/material.dart';
import 'package:train_ticket_booking_system/material/app_colors.dart';
import 'package:train_ticket_booking_system/material/app_styles.dart';
import 'package:train_ticket_booking_system/material/app_icons.dart';
import 'package:train_ticket_booking_system/material/app_images.dart';
import 'package:train_ticket_booking_system/pages/coachInfo.dart';
import 'package:train_ticket_booking_system/pages/home.dart';
import 'package:train_ticket_booking_system/pages/trainInfo.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.lightyellow,
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Image.asset(
                    AppImages.trainlogo, // Updated to logosisgg-white
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }),
          ),
          ListTile(
            leading: Image.asset(AppIcons.utamaIcon),
            title: Text('Home',
                style: ralewayStyle.copyWith(
                  fontSize: 16.0,
                  color: AppColors.darksmoke,
                  fontWeight: FontWeight.normal,
                )),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Image.asset(AppIcons.utamaIcon),
            title: Text('Train',
                style: ralewayStyle.copyWith(
                  fontSize: 16.0,
                  color: AppColors.darksmoke,
                  fontWeight: FontWeight.normal,
                )),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TrainInfoPage()),
              );
            },
          ),
          ListTile(
            leading: Image.asset(AppIcons.recordIcon),
            title: Text('Coaches & Seats',
                style: ralewayStyle.copyWith(
                  fontSize: 16.0,
                  color: AppColors.darksmoke,
                  fontWeight: FontWeight.normal,
                )),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CoachInfoPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
