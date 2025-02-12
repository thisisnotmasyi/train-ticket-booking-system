import 'package:flutter/material.dart';
import 'package:train_ticket_booking_system/auth/signinPage.dart';
import 'package:train_ticket_booking_system/auth/signupPage.dart';
import 'package:train_ticket_booking_system/material/app_colors.dart';
import 'package:train_ticket_booking_system/material/app_images.dart';
import 'package:train_ticket_booking_system/material/app_styles.dart';
import 'package:train_ticket_booking_system/widget/navBar.dart';
import 'package:train_ticket_booking_system/widget/popupSummary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoachInfoPage extends StatefulWidget {
  @override
  _CoachInfoPageState createState() => _CoachInfoPageState();
}

class _CoachInfoPageState extends State<CoachInfoPage> {
  int? selectedCoach;
  List<int> selectedSeats = [];
  final int totalCoaches = 6;
  final int seatsPerCoach = 20;
  final double farePerSeat = 20.00;
  final List<String> coachNames = [
    "COACH A",
    "COACH B",
    "COACH C",
    "COACH D",
    "COACH E",
    "COACH F"
  ];

  String? userName;
  int? pax;
  List<String> bookedSeats = [];

  Future<void> _fetchBookedSeats() async {
    QuerySnapshot seatSnapshot =
        await FirebaseFirestore.instance.collection('seat').get();
    List<String> fetchedSeats = [];

    for (var doc in seatSnapshot.docs) {
      String seatString = doc['seatNum'];
      List<String> seats = seatString.split(',').map((s) => s.trim()).toList();
      fetchedSeats.addAll(seats);
    }

    setState(() {
      bookedSeats = fetchedSeats;
    });

    print("Booked Seats: $bookedSeats");
  }

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

  Future<void> _fetchPax() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
          .collection('book')
          .doc(user.uid)
          .get();
      if (bookingDoc.exists) {
        setState(() {
          pax = bookingDoc['pax'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchPax();
    _fetchBookedSeats().then((_) {
      setState(() {});
    });
  }

  Future<void> _saveBooking() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedCoach != null && selectedSeats.isNotEmpty) {
      String coach = coachNames[selectedCoach!];
      String coachLetter = coach.split(" ").last;
      List<String> seats = selectedSeats
          .map((seatIndex) => "$coachLetter${seatIndex + 1}")
          .toList();
      double totalFare = farePerSeat * selectedSeats.length;

      await FirebaseFirestore.instance.collection('book').doc(user.uid).update({
        'seats': seats,
        'coach': coach,
        'fare': totalFare,
      });
      await FirebaseFirestore.instance.collection('seat').doc(user.uid).set({
        'seatNum': seats,
        'coachName': coach,
        'usernameC': userName,
        'paxC': pax,
        'totalFare': totalFare,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
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
            userName != null
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
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
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      }),
                      const SizedBox(width: 8),
                      _buildHoverButton('SIGN UP', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      }),
                    ],
                  )
          ],
        ),
      ),
      drawer: const Navbar(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: AppColors.darksmoke,
            child: Text(
              "Jerantut > Mengkarak\nShuttle 3",
              style: ralewayStyle.copyWith(
                color: AppColors.yellow,
                fontWeight: FontWeight.w700,
                fontSize: 25.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Text("Select Seat(s):",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        if (pax != null) Text("Please select $pax seat(s)"),
                        SizedBox(height: 16),
                        selectedCoach != null
                            ? Expanded(
                                child: SingleChildScrollView(
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                      childAspectRatio: 1.5,
                                    ),
                                    itemCount: seatsPerCoach,
                                    itemBuilder: (context, index) {
                                      bool isSelected =
                                          selectedSeats.contains(index);
                                      String seatCode =
                                          "${coachNames[selectedCoach!].split(" ").last}${index + 1}";
                                      bool isBooked = bookedSeats.any(
                                          (bookedSeat) =>
                                              bookedSeat.trim() == seatCode);

                                      return GestureDetector(
                                        onTap: isBooked
                                            ? null // Disable clicking on booked seats
                                            : () {
                                                setState(() {
                                                  if (isSelected) {
                                                    selectedSeats.remove(index);
                                                  } else {
                                                    if (pax != null &&
                                                        selectedSeats.length >=
                                                            pax!) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                "You can only select $pax seat(s)")),
                                                      );
                                                    } else {
                                                      selectedSeats.add(index);
                                                    }
                                                  }
                                                });
                                              },
                                        child: Container(
                                          margin: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isBooked
                                                ? Colors.grey
                                                : isSelected
                                                    ? Colors.green
                                                    : Colors.white,
                                            border:
                                                Border.all(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              seatCode,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : Text("Please select a coach first."),
                        SizedBox(height: 16),
                        if (selectedSeats.isNotEmpty) _buildSeatDetailsTable(),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text("Select Coach:",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: totalCoaches,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCoach = index;
                                  selectedSeats = [];
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: selectedCoach == index
                                      ? AppColors.darksmoke
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    coachNames[index],
                                    style: TextStyle(color: AppColors.yellow),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),

                        //indicator
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildIndicatorTile(Colors.green, "Selected"),
                            _buildIndicatorTile(Colors.white, "Available"),
                            _buildIndicatorTile(Colors.grey, "Not Available"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatDetailsTable() {
    String coach = coachNames[selectedCoach!];
    String coachLetter = coach.split(" ").last;
    String seatCodes = selectedSeats
        .map((seatIndex) => "$coachLetter${seatIndex + 1}")
        .join(", ");
    double totalFare = farePerSeat * selectedSeats.length;

    return Column(
      children: [
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darksmoke,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
            ],
          ),
          child: Column(
            children: [
              Text(
                "Seat Details",
                style: ralewayStyle.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.yellow),
              ),
              Divider(color: AppColors.darksmoke),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _seatDetailItem(
                              Icons.chair, "Seat Number(s)", seatCodes),
                          _seatDetailItem(
                              Icons.directions_train, "Coach", coach),
                          Row(
                            children: [
                              _seatDetailItem(Icons.attach_money, "Fare (MYR)",
                                  farePerSeat.toStringAsFixed(2)),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedSeats = [];
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                ),
                                child: Text("Reselect",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Total Fare: RM ${totalFare.toStringAsFixed(2)}",
                        style:
                            TextStyle(fontSize: 18, color: AppColors.darksmoke),
                      ),
                      SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: selectedSeats.isNotEmpty
                    ? () async {
                        print(
                            "Book Ticket pressed. Selected seats: $selectedSeats");
                        String coach = coachNames[selectedCoach!];
                        String coachLetter = coach.split(" ").last;
                        String seatCodes = selectedSeats
                            .map((seatIndex) => "$coachLetter${seatIndex + 1}")
                            .join(", ");
                        double totalFare = farePerSeat * selectedSeats.length;

                        try {
                          await _saveBooking();
                          print("Booking data saved successfully.");
                        } catch (e) {
                          print("Error while saving booking: $e");
                        }

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SummaryPopup(
                              seatNumber: seatCodes,
                              coach: coach,
                              price: "RM ${totalFare.toStringAsFixed(2)}",
                            );
                          },
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                ),
                child: Text(
                  "Book Ticket",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _seatDetailItem(IconData icon, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.darksmoke),
            SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black)),
          ],
        ),
        SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darksmoke)),
      ],
    );
  }
}

// Indicator tile widget.
Widget _buildIndicatorTile(Color color, String label) {
  return Row(
    children: [
      Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: color, border: Border.all()),
      ),
      SizedBox(width: 8),
      Text(label),
    ],
  );
}

//button sign in sign up
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
                ? [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3))
                  ]
                : [],
          ),
          child: GestureDetector(
            onTap: onPressed,
            child:
                Text(text, style: TextStyle(color: Colors.black, fontSize: 14)),
          ),
        ),
      );
    },
  );
}
