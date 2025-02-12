import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:train_ticket_booking_system/auth/signinPage.dart';
import 'package:train_ticket_booking_system/auth/signupPage.dart';
import 'package:train_ticket_booking_system/pages/trainInfo.dart';
import 'package:train_ticket_booking_system/widget/navBar.dart';
import 'package:train_ticket_booking_system/material/app_images.dart';
import 'package:train_ticket_booking_system/widget/popupWindows.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Form fields.
  String tripType = "One Way";
  String? fromCity;
  String? toCity;
  DateTime? departDate;
  DateTime? returnDate;
  int adultCount = 0;
  int childCount = 0;
  bool _isSignedIn = false;
  String? userName;
  List<String> locations = [
    "Butterworth",
    "Ipoh",
    "Tanah Merah",
    "Gemas",
    "Kuala Lumpur"
  ];

  //fetch full name from 'customer'
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

  Future<void> _selectDate(BuildContext context, bool isDepart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isDepart) {
          departDate = picked;
        } else {
          returnDate = picked;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Check if the user is already signed in.
    if (FirebaseAuth.instance.currentUser != null) {
      _isSignedIn = true;
      _fetchUserName();
    } else {
      // If not signed in, show the login popup after the first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        bool? result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => LoginPopup(),
        );
        if (result == true) {
          setState(() {
            _isSignedIn = true;
          });
          _fetchUserName();
        }
      });
    }
  }

  Future<void> _submitBooking() async {
    // Check required fields.
    if (fromCity == null ||
        toCity == null ||
        departDate == null ||
        (tripType == "Round - Trip" && returnDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    int pax = adultCount + childCount;

    try {
      // Prepare the booking data.
      Map<String, dynamic> bookingData = {
        'origin': fromCity,
        'destination': toCity,
        'selectedDate': Timestamp.fromDate(departDate!),
        'timestamp': FieldValue.serverTimestamp(),
        'pax': pax,
        'fullnameB': userName,
        'tripType': tripType,
      };

      // If this is a round trip, add the return date.
      if (tripType == "Round - Trip") {
        bookingData['returnDate'] = Timestamp.fromDate(returnDate!);
      }

      // Store the booking data in the 'book' collection.
      await FirebaseFirestore.instance.collection('book').add(bookingData);

      // Navigate to TrainInfoPage.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TrainInfoPage()),
      );
    } catch (e) {
      // Handle any errors.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error storing booking: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with a logo, title, and either the user's name with logout or sign in/up buttons.
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
            // If the user is signed in (i.e. userName is available), show the username with a logout option.
            // Otherwise, show Sign In / Sign Up buttons.
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
      body: Stack(
        children: [
          // Background image.
          Positioned.fill(
            child: Image.asset(
              AppImages.trainbg,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Booking form container.
                  Container(
                    width: 600,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Book Your Ticket Today",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildTripButton("One Way"),
                            _buildTripButton("Round - Trip"),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildDropdown("From", fromCity, "Origin",
                            (newValue) => setState(() => fromCity = newValue)),
                        _buildDropdown("To", toCity, "Destination",
                            (newValue) => setState(() => toCity = newValue)),
                        _buildDateField("Depart", departDate, true),
                        if (tripType == "Round - Trip")
                          _buildDateField("Return", returnDate, false),
                        const SizedBox(height: 10),
                        _buildPassengerCounter("Adult", adultCount,
                            (value) => setState(() => adultCount = value)),
                        _buildPassengerCounter("Child", childCount,
                            (value) => setState(() => childCount = value)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                            ),
                            onPressed: _submitBooking,
                            child: const Text(
                              "Continue",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 230),
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Image.asset(
                          AppImages.trainticket,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //tripType button
  Widget _buildTripButton(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: tripType == title ? Colors.yellow : Colors.grey[300],
        ),
        onPressed: () => setState(() => tripType = title),
        child: Text(title, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  //location's dropdown button
  Widget _buildDropdown(
      String label, String? value, String hint, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          items: locations.map((location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Text(location),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isDepart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        InkWell(
          onTap: () => _selectDate(context, isDepart),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              date != null
                  ? "${date.day} ${_monthString(date.month)} ${date.year}"
                  : "Choose Date",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerCounter(
      String label, int count, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$count $label"),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.remove,
                color: count > 0 ? Colors.black : Colors.grey,
              ),
              onPressed: count > 0 ? () => onChanged(count - 1) : null,
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.yellow),
              onPressed: () => onChanged(count + 1),
            ),
          ],
        ),
      ],
    );
  }

  String _monthString(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isHovered ? Colors.grey[300] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isHovered
                ? const [
                    // BoxShadow(
                    //     color: Colors.black26,
                    //     blurRadius: 6,
                    //     offset: Offset(0, 3))
                  ]
                : [],
          ),
          child: GestureDetector(
            onTap: onPressed,
            child: Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
        ),
      );
    },
  );
}
