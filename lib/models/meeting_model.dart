class MeetingResponse {
  final bool success;
  final List<Meeting> data;

  MeetingResponse({
    required this.success,
    required this.data,
  });

  factory MeetingResponse.fromJson(Map<String, dynamic> json) {
    return MeetingResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((item) => Meeting.fromJson(item))
          .toList(),
    );
  }
}

class Meeting {
  final int id;
  final String subject;
  final String date;
  final String formattedDate;
  final String fromTime;
  final String toTime;
  final String? liveLink;
  final String? recordingLink;
  final String? remarks;
  final String status;

  Meeting({
    required this.id,
    required this.subject,
    required this.date,
    required this.formattedDate,
    required this.fromTime,
    required this.toTime,
    this.liveLink,
    this.recordingLink,
    this.remarks,
    required this.status,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] ?? 0,
      subject: json['subject'] ?? '',
      date: json['date'] ?? '',
      formattedDate: json['formatted_date'] ?? '',
      fromTime: json['from_time'] ?? '',
      toTime: json['to_time'] ?? '',
      liveLink: json['live_link'],
      recordingLink: json['recording_link'],
      remarks: json['remarks'],
      status: json['status'] ?? '',
    );
  }

  DateTime get startDateTime {
    return _parseDateTime(date, fromTime);
  }

  DateTime get endDateTime {
    return _parseDateTime(date, toTime);
  }

  DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      final ampm = parts[1].toLowerCase();

      if (ampm == 'pm' && hour < 12) hour += 12;
      if (ampm == 'am' && hour == 12) hour = 0;

      final dateParts = dateStr.split('-');
      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        hour,
        minute,
      );
    } catch (e) {
      return DateTime.now();
    }
  }
}
