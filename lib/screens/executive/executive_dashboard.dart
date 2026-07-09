import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/core/mock_data_generator.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/models/executive_task_model.dart';

import 'package:provider/provider.dart';
import 'package:practice_app/providers/global_app_state.dart';

class ExecutiveDashboard extends StatelessWidget {
  const ExecutiveDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    
    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = MockDataGenerator.getExecutiveStats();
    final tasks = state.tasks;
    final inFmt = NumberFormat('#,##,###', 'en_IN');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Large tappable stat cards
          Row(children: [
            Expanded(child: _BigCard(
              title: "Today's Drops", value: '${stats['todaysDrops']}',
              icon: Icons.local_shipping, color: AppColors.navyBlue)),
            const SizedBox(width: 12),
            Expanded(child: _BigCard(
              title: 'Pending Pay', value: '${stats['pendingPayments']}',
              icon: Icons.payment, color: AppColors.urgentAmber)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _BigCard(
              title: 'Completed', value: '${stats['completedToday']}',
              icon: Icons.check_circle, color: AppColors.successGreen)),
            const SizedBox(width: 12),
            Expanded(child: _BigCard(
              title: 'Monthly Bonus', value: '₹${inFmt.format(stats['monthlyBonus'])}',
              icon: Icons.emoji_events, color: AppColors.gold)),
          ]),
          const SizedBox(height: 24),
          Text("Today's Tasks", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...tasks.take(8).map((task) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(task.type.displayName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gold)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: task.status.name == 'completed'
                            ? AppColors.successGreen.withValues(alpha: 0.1)
                            : AppColors.urgentAmber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(task.status.displayName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: task.status.name == 'completed' ? AppColors.successGreen : AppColors.urgentAmber)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(task.clientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(task.clientAddress, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
                  if (task.maidName != null) ...[
                    const SizedBox(height: 4),
                    Text('Maid: ${task.maidName}', style: const TextStyle(fontSize: 13, color: AppColors.navyBlue)),
                  ],
                  const SizedBox(height: 8),
                  Row(children: [
                    if (task.gpsLink != null)
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.navigation, size: 16),
                        label: const Text('Navigate'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navyBlue,
                          textStyle: const TextStyle(fontSize: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    const Spacer(),
                    if (task.status != TaskStatus.completed)
                      ElevatedButton.icon(
                        onPressed: () {
                          state.markTaskCompleted(task.id);
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Mark Completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      )
                    else if (task.paymentAmount != null)
                      Text('₹${inFmt.format(task.paymentAmount!.toInt())}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold)),
                  ]),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _BigCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
