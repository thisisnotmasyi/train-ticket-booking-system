import 'package:flutter/material.dart';
import 'package:train_ticket_booking_system/material/app_colors.dart';
import 'package:train_ticket_booking_system/material/app_styles.dart';

class EditBookingPopup extends StatefulWidget {
  @override
  _EditBookingPopupState createState() => _EditBookingPopupState();
}

class _EditBookingPopupState extends State<EditBookingPopup> {
  String? fromCity;
  String? toCity;
  DateTime? departDate;
  DateTime? returnDate;
  int adultCount = 1;
  int childCount = 0;
  bool isRoundTrip = false;

  void _selectDate(BuildContext context, bool isDepart) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isDepart) {
          departDate = pickedDate;
        } else {
          returnDate = pickedDate;
        }
      });
    }
  }

  void _submitBooking() {
    // Handle booking logic
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: AppColors.textColor, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Center(
                child: Text(
                  "Edit Your Booking",
                  style: ralewayStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontSize: 22.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "From",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                value: fromCity,
                items: [
                  "Butterworth",
                  "Ipoh",
                  "Tanah Merah",
                  "Gemas",
                  "Kuala Lumpur"
                ]
                    .map((city) =>
                        DropdownMenuItem(value: city, child: Text(city)))
                    .toList(),
                onChanged: (value) => setState(() => fromCity = value),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "To",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                value: toCity,
                items: [
                  "Butterworth",
                  "Ipoh",
                  "Tanah Merah",
                  "Gemas",
                  "Kuala Lumpur"
                ]
                    .map((city) =>
                        DropdownMenuItem(value: city, child: Text(city)))
                    .toList(),
                onChanged: (value) => setState(() => toCity = value),
              ),
              SizedBox(height: 10),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                tileColor: Colors.grey[200],
                title: Text(
                    "Depart Date: ${departDate?.toLocal().toString().split(' ')[0] ?? "Select Date"}"),
                trailing: Icon(Icons.calendar_today, color: AppColors.black),
                onTap: () => _selectDate(context, true),
              ),
              if (isRoundTrip)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    tileColor: Colors.grey[200],
                    title: Text(
                        "Return Date: ${returnDate?.toLocal().toString().split(' ')[0] ?? "Select Date"}"),
                    trailing:
                        Icon(Icons.calendar_today, color: AppColors.black),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Adults: $adultCount", style: TextStyle(fontSize: 14.0)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: AppColors.black),
                        onPressed: () => setState(() =>
                            adultCount = (adultCount > 1) ? adultCount - 1 : 1),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: AppColors.black),
                        onPressed: () => setState(() => adultCount++),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Children: $childCount",
                      style: TextStyle(fontSize: 14.0)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: AppColors.black),
                        onPressed: () => setState(() =>
                            childCount = (childCount > 0) ? childCount - 1 : 0),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: AppColors.black),
                        onPressed: () => setState(() => childCount++),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  onPressed: _submitBooking,
                  child: Text("Continue",
                      style: TextStyle(color: Colors.black, fontSize: 14.0)),
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
