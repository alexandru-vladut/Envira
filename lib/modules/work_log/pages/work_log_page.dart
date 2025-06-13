import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/modules/custom_app_bar.dart';
import 'package:flutter_app_base/modules/work_log/providers/work_log_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class WorkLogPage extends StatefulWidget {
  const WorkLogPage({super.key});

  @override
  State<WorkLogPage> createState() => _WorkLogPageState();
}

class _WorkLogPageState extends State<WorkLogPage> with SingleTickerProviderStateMixin {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  int? _selectedCheckbox;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // For transport method and distance input
  String? _selectedTransportMethod;
  final TextEditingController _distanceController = TextEditingController();
  bool _isSubmittingTransport = false;

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
  bool _isDateLogged(DateTime day, List<DateTime> loggedDates) {
    return loggedDates.any((loggedDate) => 
      isSameDay(loggedDate, day)
    );
  }

  @override
  Widget build(BuildContext context) {
    return WorkLogProvider(
      builder: (data) {
        // If newPoints is null, show the setup page
        if (data.newPoints == null) {
          return _buildTransportSetupPage(context);
        }

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
                    _buildCalendar(data.loggedDates),
                    const SizedBox(height: 16),
                    _buildCalendarLegend(),
                    const SizedBox(height: 24),
                    if (_selectedDay != null) ...[
                      _buildSelectedDayInfo(),
                      const SizedBox(height: 16),
                      _buildWorkOptions(),
                      const SizedBox(height: 16),
                      if (_selectedCheckbox != null) _buildPointsInfo(data),
                      const SizedBox(height: 24),
                      if (_selectedCheckbox != null) _buildSubmitButton(data),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildTransportSetupPage(BuildContext context) {
    final transportOptions = [
      {'method': 'car', 'icon': Icons.directions_car, 'color': CustomTheme.errorRed},
      {'method': 'public transit', 'icon': Icons.directions_bus, 'color': CustomTheme.mediumBlue},
      {'method': 'bike', 'icon': Icons.directions_bike, 'color': CustomTheme.successGreen},
      {'method': 'walk', 'icon': Icons.directions_walk, 'color': CustomTheme.primaryGreen},
      {'method': 'mixed', 'icon': Icons.shuffle, 'color': CustomTheme.darkBlue1},
    ];

    // Initialize distance value for slider
    double _distance = double.tryParse(_distanceController.text) ?? 5.0;
    
    return Scaffold(
      backgroundColor: CustomTheme.white,
      appBar: CustomAppBar(title: 'Set Up Work Log'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomTheme.lightGreenAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CustomTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: CustomTheme.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Complete your profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CustomTheme.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tell us how you usually commute to earn points for working from home',
                            style: TextStyle(
                              fontSize: 14,
                              color: CustomTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Transport method section
              Text(
                'How do you usually get to work?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CustomTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 16),
              
              // Transport options as cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: transportOptions.length,
                itemBuilder: (context, index) {
                  final option = transportOptions[index];
                  final isSelected = _selectedTransportMethod == option['method'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTransportMethod = option['method'] as String;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? (option['color'] as Color).withOpacity(0.1) 
                            : CustomTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? option['color'] as Color
                              : CustomTheme.grey200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: (option['color'] as Color).withOpacity(0.2),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? option['color'] as Color
                                  : (option['color'] as Color).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              option['icon'] as IconData,
                              color: isSelected 
                                  ? CustomTheme.white
                                  : option['color'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (option['method'] as String)
                                .split(' ')
                                .map((word) => word[0].toUpperCase() + word.substring(1))
                                .join(' '),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                  ? option['color'] as Color
                                  : CustomTheme.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Distance section with slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Distance to office (km)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CustomTheme.darkGrey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: CustomTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setStateLocal) {
                        return Text(
                          '${_distance.toInt()} km',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CustomTheme.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Slider for distance
              StatefulBuilder(
                builder: (context, setStateLocal) {
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: CustomTheme.primaryGreen,
                          inactiveTrackColor: CustomTheme.lightGrey,
                          thumbColor: CustomTheme.primaryGreen,
                          overlayColor: CustomTheme.primaryGreen.withOpacity(0.2),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                        ),
                        child: Slider(
                          min: 1,
                          max: 100,
                          divisions: 99,
                          value: _distance,
                          onChanged: (value) {
                            setStateLocal(() {
                              _distance = value;
                              _distanceController.text = value.toInt().toString();
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '1 km',
                            style: TextStyle(
                              fontSize: 12,
                              color: CustomTheme.grey600,
                            ),
                          ),
                          Text(
                            '100 km',
                            style: TextStyle(
                              fontSize: 12,
                              color: CustomTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Manual input option
                      TextField(
                        controller: _distanceController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CustomTheme.darkGrey,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Or enter exact distance',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: CustomTheme.grey600,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: CustomTheme.grey200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: CustomTheme.primaryGreen, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          suffixText: 'km',
                          suffixStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CustomTheme.grey600,
                          ),
                        ),
                        onChanged: (value) {
                          final distance = double.tryParse(value);
                          if (distance != null && distance > 0 && distance <= 100) {
                            setStateLocal(() {
                              _distance = distance;
                            });
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmittingTransport
                      ? null
                      : () async {
                          final distance = int.tryParse(_distanceController.text.trim());
                          if (_selectedTransportMethod == null ||
                              distance == null ||
                              distance <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.white),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Please select a transport method and enter a valid distance.',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: CustomTheme.errorRed,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                            return;
                          }
                          setState(() => _isSubmittingTransport = true);
                          await workLogService.updateUserTransportAndDistance(
                            context: context,
                            transportMethod: _selectedTransportMethod!,
                            distanceToOffice: distance,
                          );
                          setState(() => _isSubmittingTransport = false);
                        },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: CustomTheme.white,
                    backgroundColor: CustomTheme.primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmittingTransport
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: CustomTheme.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 24),
                            const SizedBox(width: 12),
                            const Text(
                              'Complete Setup',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
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

  Widget _buildCalendar(List<DateTime> loggedDates) {
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
            if (!_isDateLogged(selectedDay, loggedDates)) {
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
            return !_isDateLogged(day, loggedDates);
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
              if (_isDateLogged(day, loggedDates)) {
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

  Widget _buildPointsInfo(WorkLogData data) {
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
        ? 'You will gain ${data.newPoints} points!'
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

  Widget _buildSubmitButton(WorkLogData data) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => workLogService.logWork(context, _selectedDay!, data.newPoints!),
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
