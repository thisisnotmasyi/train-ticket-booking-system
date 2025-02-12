import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:train_ticket_booking_system/material/app_colors.dart';
import 'package:train_ticket_booking_system/material/app_styles.dart';
import 'package:train_ticket_booking_system/pages/confirmBook.dart';

class SummaryPopup extends StatelessWidget {
  final String seatNumber;
  final String coach;
  final String price;

  SummaryPopup(
      {required this.seatNumber, required this.coach, required this.price});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Booking Summary",
                style: ralewayStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontSize: 22.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1.5),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: AppColors.yellow),
                        children: [
                          _buildTableHeader("Seat Number"),
                          _buildTableHeader("Coach"),
                          _buildTableHeader("Price"),
                        ],
                      ),
                      TableRow(
                        decoration: BoxDecoration(color: Colors.white),
                        children: [
                          _buildTableCell(seatNumber),
                          _buildTableCell(coach),
                          _buildTableCell(price),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(), // Close popup
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 20.0),
                    ),
                    child: Text(
                      "Back",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await storeSeatData(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 20.0),
                    ),
                    child: Text(
                      "Proceed Payment",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> storeSeatData(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Fetch user details from 'book' database
      QuerySnapshot bookSnapshot =
          await firestore.collection('book').limit(1).get();
      if (bookSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Booking data not found!")));
        return;
      }

      var bookData = bookSnapshot.docs.first.data() as Map<String, dynamic>;
      String username = bookData['fullnameB'] ?? 'Unknown';
      int pax = bookData['pax'] ?? 1;

      // Store data in 'seat' database
      await firestore.collection('seat').add({
        'seatNum': seatNumber,
        'coachName': coach,
        'totalFare': price,
        'timestamp': FieldValue.serverTimestamp(),
        'usernameC': username,
        'paxC': pax,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ConfirmBook()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error storing data: $e")));
    }
  }
}
