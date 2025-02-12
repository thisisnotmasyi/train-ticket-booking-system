import 'package:flutter/material.dart';
import 'package:train_ticket_booking_system/auth/signinPage.dart';
import 'package:train_ticket_booking_system/auth/signupPage.dart';
import 'package:train_ticket_booking_system/material/app_colors.dart';
import 'package:train_ticket_booking_system/material/app_images.dart';
import 'package:train_ticket_booking_system/pages/coachInfo.dart';
import 'package:train_ticket_booking_system/widget/navBar.dart';
import 'package:train_ticket_booking_system/widget/popupEdit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainInfoPage extends StatefulWidget {
  @override
  _TrainInfoPageState createState() => _TrainInfoPageState();
}

class _TrainInfoPageState extends State<TrainInfoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? userName;
  String fromCity = "JENDERAK";
  String toCity = "KUALA KRAU";

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('customer')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['cFullname'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _fetchUserName();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Row(
          children: [
            Image.asset(AppImages.trainlogo, height: 80),
            const SizedBox(width: 10),
            const Text(
              "Train Ticket Booking",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // If the user is signed in, show username with a logout option.
            // Otherwise, show Sign In / Sign Up buttons.
            userName != null
                ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
              child: Text(
                userName!,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text("Log Out"),
                ),
              ],
            )
                : Row(
              children: [
                _buildHoverButton('SIGN IN', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }),
                const SizedBox(width: 8),
                _buildHoverButton('SIGN UP', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                }),
              ],
            )
          ],
        ),
      ),
      drawer: const Navbar(),
      body: Row(
        children: [
          Container(
            width: 270,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('JOURNEY PLAN',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueGrey[800])),
                SizedBox(height: 12),
                Text('$fromCity to $toCity',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                Divider(color: Colors.grey[500], thickness: 1),
                SizedBox(height: 8),
                Text('Departure',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('27 Feb 2025', style: TextStyle(fontSize: 14, color: Colors.black54)),
                SizedBox(height: 8),
                Text('1 Pax', style: TextStyle(fontSize: 14, color: Colors.black54)),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => EditBookingPopup(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darksmoke,
                    foregroundColor: AppColors.yellow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Center(child: Text('MODIFY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.darksmoke,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
                    ],
                  ),
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$fromCity ➤ $toCity',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: AppColors.darksmoke,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'Mon, 24 Feb'),
                      Tab(text: 'Tue, 25 Feb'),
                      Tab(text: 'Wed, 26 Feb'),
                      Tab(text: 'Thu, 27 Feb'),
                      Tab(text: 'Fri, 28 Feb'),
                      Tab(text: 'Sat, 1 Mar'),
                    ],
                  ),
                ),
                // Train List
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(12),
                    children: [
                      _trainCard('Shuttle - 35', '11:36', '12:48', '1 hour 12 min', 198, 'MYR 12.00', context),
                      _trainCard('Shuttle - 98', '12:26', '13:38', '1 hour12 min', 197, 'MYR 12.50', context),
                      _trainCard('Shuttle - 62', '14:12', '15:24', '1 hour 12 min', 197, 'MYR 13.00', context),
                      _trainCard('Shuttle - 32', '16:15', '17:20', '1 hour 5 min', 197, 'MYR 11.90', context),
                      _trainCard('Shuttle - 46', '18:30', '19:38', '1 hour 8 min', 197, 'MYR 14.50', context),
                      _trainCard('Shuttle - 7', '20:45', '21:50', '1 hour 5 min', 197, 'MYR 15.00', context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget trainCard(String train, String departure, String arrival, String duration, int seats, String fare) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(flex: 3, child: Text(train, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            Expanded(child: Text(departure, style: TextStyle(fontSize: 14))),
            Expanded(child: Text(arrival, style: TextStyle(fontSize: 14))),
            Expanded(child: Text(duration, style: TextStyle(fontSize: 14))),
            Expanded(child: Text('$seats seats', style: TextStyle(fontSize: 14))),
            Expanded(child: Text(fare, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: Text('Pick Seats', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildHoverButton(String text, VoidCallback onPressed) {
  return StatefulBuilder(
    builder: (context, setState) {
      bool isHovered = false;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isHovered ? Colors.grey[300] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isHovered
                ? [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))]
                : [],
          ),
          child: GestureDetector(
            onTap: onPressed,
            child: Text(text, style: TextStyle(color: Colors.black, fontSize: 14)),
          ),
        ),
      );
    },
  );
}

Widget _trainCard(String trainName, String depTime, String arrTime, String duration, int seats, String price, BuildContext context) {
  return InkWell(
    onTap: () async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('customer').doc(user.uid).get();

        if (userDoc.exists) {
          String userName = userDoc['cFullname'];

          await FirebaseFirestore.instance.collection('train').add({
            'username': userName,
            'selected_shuttle': trainName,
            'price': price,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // confirmation notif
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$trainName booked successfully for $userName!')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CoachInfoPage()),
          );
        }
      } else {
        // If no user is logged in, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please sign in to book a train.')),
        );
      }
    },
    borderRadius: BorderRadius.circular(12),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainName,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                SizedBox(height: 6),
                Text('$depTime ➤ $arrTime',
                    style: TextStyle(fontSize: 14, color: Colors.black87)),
                SizedBox(height: 4),
                Text(duration,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800])),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
