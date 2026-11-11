import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../models/grade_model.dart';
import '../../core/constants/app_colors.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = 1; // 1 = Senin

  final List<Map<String, dynamic>> _days = [
    {'day': 1, 'name': 'Senin'},
    {'day': 2, 'name': 'Selasa'},
    {'day': 3, 'name': 'Rabu'},
    {'day': 4, 'name': 'Kamis'},
    {'day': 5, 'name': 'Jumat'},
  ];

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);
    final daySchedules =
        academic.schedules.where((s) => s.dayOfWeek == _selectedDay).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Jadwal Pelajaran'),
      ),
      body: Column(
        children: [
          // Day selector chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _days.map((item) {
                  final isSelected = item['day'] == _selectedDay;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(item['name']),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.backgroundLight,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondaryLight,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onSelected: (val) {
                        if (val) setState(() => _selectedDay = item['day']);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (daySchedules.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        Icon(Icons.event_busy_rounded,
                            size: 48, color: AppColors.textMutedLight),
                        SizedBox(height: 12),
                        Text(
                          'Tidak ada kelas terjadwal untuk hari ini.',
                          style: TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ...daySchedules.map((item) => _buildScheduleItem(item)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(ScheduleModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.subjectCode,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: AppColors.textMutedLight),
                  const SizedBox(width: 4),
                  Text(
                    '${item.startTime} - ${item.endTime}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.subjectName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_pin_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.teacherName,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondaryLight),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.room,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
