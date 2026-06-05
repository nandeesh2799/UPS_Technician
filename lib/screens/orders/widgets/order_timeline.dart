import 'package:flutter/material.dart';

class OrderTimeline extends StatelessWidget {
  final String currentStatus;

  const OrderTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final statuses = ['Pending', 'In Progress', 'Waiting for Parts', 'Completed', 'Delivered'];
    int currentIndex = statuses.indexOf(currentStatus);
    if (currentIndex == -1) {
      if (currentStatus == 'Assigned') {
        currentIndex = 0;
      } else if (currentStatus == 'Diagnosed') {
        currentIndex = 1;
      } else {
        currentIndex = 0;
      }
    }

    return SizedBox(
      height: 100,
      child: Row(
        children: List.generate(statuses.length, (index) {
          bool isCompleted = index <= currentIndex;
          bool isLast = index == statuses.length - 1;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0 ? Colors.transparent : (isCompleted ? Theme.of(context).primaryColor : Colors.grey.shade300),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted ? Theme.of(context).primaryColor : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isLast ? Colors.transparent : (index < currentIndex ? Theme.of(context).primaryColor : Colors.grey.shade300),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  statuses[index].replaceAll(' ', '\n'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
