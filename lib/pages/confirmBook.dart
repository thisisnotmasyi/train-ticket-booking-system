import 'package:flutter/material.dart';
import 'package:train_ticket_booking_system/material/app_images.dart';

class ConfirmBook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shuttle-35' ' Mashita',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '18 June 2023',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildTicketRow('From', 'Pati', 'To', 'Kudus'),
                    _buildTicketRow('Departure', '08:00 AM', 'Arrival', '09:00 AM'),
                    _buildTicketRow('Coach', 'Coach A', 'Seat', 'A12'),
                    _buildTicketRow('Trip', 'One-Way', 'Passenger', '1 Pax'),
                  ],
                ),
              ),

              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: -15, // Moves the left circle outwards
                    child: _enlargedPerforationCircle(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DashedLine(
                      dashWidth: 5,
                      dashSpace: 3,
                      height: 1,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Positioned(
                    right: -15, // Moves the right circle outwards
                    child: _enlargedPerforationCircle(),
                  ),
                ],
              ),


              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(AppImages.trainqr, height: 100),
                    const SizedBox(height: 10),
                    Text(
                      "Scan QR For Details",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ticketInfo(label1, value1),
          _ticketInfo(label2, value2),
        ],
      ),
    );
  }

  Widget _ticketInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _enlargedPerforationCircle() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        shape: BoxShape.circle,
      ),
    );
  }
}

class DashedLine extends StatelessWidget {
  final double dashWidth;
  final double dashSpace;
  final double height;
  final Color color;

  const DashedLine({
    Key? key,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.height = 1,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalLength = constraints.maxWidth;
        int dashCount = (totalLength / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}