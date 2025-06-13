import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/app_config.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/modules/custom_app_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with SingleTickerProviderStateMixin {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  int? _selectedCheckbox;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // List of dates that have already been logged
  final List<DateTime> _loggedDates = [
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now().subtract(const Duration(days: 3)),
    DateTime.now().subtract(const Duration(days: 5)),
    DateTime.now().subtract(const Duration(days: 8)),
    DateTime.now().subtract(const Duration(days: 14)),
    DateTime.now().subtract(const Duration(days: 21)),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Check if a date has already been logged
  bool _isDateLogged(DateTime day) {
    return _loggedDates.any((loggedDate) => 
      isSameDay(loggedDate, day)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.white,
      appBar: CustomAppBar(title: 'Work'),
      body: SizedBox(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildCalendarHeader(),
                const SizedBox(height: 16),
                _buildCalendar(),
                const SizedBox(height: 16),
                _buildCalendarLegend(),
                const SizedBox(height: 24),
                if (_selectedDay != null) ...[
                  _buildSelectedDayInfo(),
                  const SizedBox(height: 16),
                  _buildWorkOptions(),
                  const SizedBox(height: 16),
                  if (_selectedCheckbox != null) _buildPointsInfo(),
                  const SizedBox(height: 24),
                  if (_selectedCheckbox != null) _buildSubmitButton(),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomTheme.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: CustomTheme.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Work Log Calendar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomTheme.darkGrey,
                ),
              ),
              Text(
                'Track work location and earn points',
                style: TextStyle(
                  fontSize: 14,
                  color: CustomTheme.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            color: CustomTheme.primaryGreen, 
            label: 'Selected',
          ),
          const SizedBox(width: 14),
          _buildLegendItem(
            icon: Icons.check_circle,
            color: CustomTheme.mediumBlue,
            label: 'Already logged',
          ),
          const SizedBox(width: 14),
          _buildLegendItem(
            icon: Icons.block,
            color: CustomTheme.grey400,
            label: 'Unavailable',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    IconData? icon,
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        icon != null
            ? Icon(icon, size: 16, color: color)
            : Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: CustomTheme.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: CustomTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TableCalendar(
          firstDay: DateTime.utc(2022, 1, 1),
          lastDay: DateTime.now(),
          startingDayOfWeek: StartingDayOfWeek.monday,
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.twoWeeks,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.twoWeeks: '2 Weeks',
            CalendarFormat.week: 'Week',
          },
          onDaySelected: (selectedDay, focusedDay) {
            // Only process selection if the day is not already logged
            if (!_isDateLogged(selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedCheckbox = null;
                _animationController.reset();
                _animationController.forward();
              });
            }
          },
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          enabledDayPredicate: (day) {
            // Return false for logged dates to make them appear disabled
            return !_isDateLogged(day);
          },
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CustomTheme.darkGrey,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: CustomTheme.primaryGreen,
              size: 28,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: CustomTheme.primaryGreen,
              size: 28,
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: CustomTheme.primaryGreen.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: CustomTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            weekendTextStyle: TextStyle(color: CustomTheme.grey600),
            outsideTextStyle: TextStyle(color: CustomTheme.grey400),
            // Styling for dates beyond the allowed range (future dates)
            disabledTextStyle: TextStyle(
              color: CustomTheme.grey400.withOpacity(0.5),
              fontSize: 14,
            ),
            // Custom styling for already logged dates
            markersMaxCount: 1,
            markersAnchor: 0.7,
            markerDecoration: const BoxDecoration(
              color: CustomTheme.transparent,
            ),
            // Adding builder for custom day rendering
            cellMargin: const EdgeInsets.all(4),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: CustomTheme.darkGrey,
            ),
            weekendStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: CustomTheme.grey600,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            // Custom builder for disabled days (already logged)
            disabledBuilder: (context, day, focusedDay) {
              if (_isDateLogged(day)) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: CustomTheme.lightBlueAccent.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: CustomTheme.mediumBlue,
                            fontWeight: FontWeight.w500,
                            fontSize: 16, // Match size with other dates
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Icon(
                          Icons.check_circle,
                          color: CustomTheme.mediumBlue,
                          size: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }
              // Default for other disabled days (e.g., beyond range)
              return null;
            },
            // For default cell rendering
            defaultBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: CustomTheme.darkGrey,
                    fontSize: 16, // Set consistent font size
                  ),
                ),
              );
            },
            // Make sure selected days have the same dimensions
            selectedBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CustomTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: CustomTheme.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Match size with other dates
                  ),
                ),
              );
            },
            // Make sure today has the same dimensions
            todayBuilder: (context, day, focusedDay) {
              final isSelected = isSameDay(day, _selectedDay);
              return Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected 
                    ? CustomTheme.primaryGreen 
                    : CustomTheme.primaryGreen.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isSelected ? CustomTheme.white : CustomTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Match size with other dates
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayInfo() {
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: CustomTheme.lightGreenAccent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomTheme.lightGreenBorder),
        ),
        child: Row(
          children: [
            Icon(
              Icons.today_rounded,
              color: CustomTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CustomTheme.darkGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkOptions() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'How did you work today?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CustomTheme.darkGrey,
              ),
            ),
          ),
          _buildWorkOption(
            1,
            'Work from home',
            Icons.home_rounded,
            CustomTheme.successGreen,
            CustomTheme.lightGreenAccent,
          ),
          const SizedBox(height: 12),
          _buildWorkOption(
            2,
            'Work in office',
            Icons.apartment_rounded,
            CustomTheme.mediumBlue,
            CustomTheme.lightBlueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOption(
    int value,
    String title,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
  ) {
    final isSelected = _selectedCheckbox == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCheckbox = isSelected ? null : value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? backgroundColor : CustomTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? iconColor : CustomTheme.grey200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: iconColor.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(isSelected ? 1.0 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? CustomTheme.white : iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? iconColor : CustomTheme.darkGrey,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? iconColor : CustomTheme.white,
                border: Border.all(
                  color: isSelected ? iconColor : CustomTheme.grey400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: CustomTheme.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsInfo() {
    final isWorkFromHome = _selectedCheckbox == 1;
    final backgroundColor = isWorkFromHome
        ? CustomTheme.lightGreenAccent
        : CustomTheme.errorRed.withOpacity(0.1);
    final borderColor = isWorkFromHome
        ? CustomTheme.lightGreenBorder
        : CustomTheme.errorRed.withOpacity(0.3);
    final textColor = isWorkFromHome
        ? CustomTheme.successGreenDark
        : CustomTheme.errorRedDark;
    final icon = isWorkFromHome
        ? Icons.eco_rounded
        : Icons.do_not_disturb_rounded;
    final message = isWorkFromHome
        ? 'You will gain ${AppConfig.workFromHomePoints} points!'
        : 'You won\'t gain any points.';
    final description = isWorkFromHome
        ? 'Thank you for saving office resources!'
        : 'Consider working from home when possible.';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isWorkFromHome
                    ? CustomTheme.successGreen
                    : CustomTheme.errorRed,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: CustomTheme.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => workLogService.logWork(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: CustomTheme.white,
            backgroundColor: CustomTheme.primaryGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 24),
              const SizedBox(width: 12),
              Text(
                'Submit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
