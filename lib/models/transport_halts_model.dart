import 'package:smart_aig_admins_app/models/transport_location_requests_model.dart';

class TransportHaltsResponse {
  final bool success;
  final String? message;
  final TransportHaltsData? data;

  TransportHaltsResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory TransportHaltsResponse.fromJson(Map<String, dynamic> json) {
    bool isSuccess = json['success'] ?? true;
    String? msg = json['message']?.toString();

    TransportHaltsData? haltsData;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      haltsData = TransportHaltsData.fromJson(json['data']);
    } else if (json['halts'] != null) {
      haltsData = TransportHaltsData.fromJson(json);
    }

    return TransportHaltsResponse(
      success: isSuccess,
      message: msg,
      data: haltsData,
    );
  }
}

class TransportHaltsData {
  final List<TransportHalt> halts;
  final PaginationInfo? pagination;

  TransportHaltsData({
    required this.halts,
    this.pagination,
  });

  factory TransportHaltsData.fromJson(Map<String, dynamic> json) {
    List haltsList = [];
    if (json['halts'] is List) {
      haltsList = json['halts'];
    } else if (json['data'] is List) {
      haltsList = json['data'];
    }

    List<TransportHalt> parsedHalts = haltsList
        .whereType<Map<String, dynamic>>()
        .map((i) => TransportHalt.fromJson(i))
        .toList();

    PaginationInfo? pagination;
    if (json['pagination'] != null && json['pagination'] is Map<String, dynamic>) {
      pagination = PaginationInfo.fromJson(json['pagination']);
    }

    return TransportHaltsData(
      halts: parsedHalts,
      pagination: pagination,
    );
  }
}

class TransportHalt {
  final int id;
  final TransportHaltBus? bus;
  final TransportHaltTrip? trip;
  final String? startedAt;
  final String? startedAtTime;
  final String? endedAt;
  final String? endedAtTime;
  final bool isOngoing;
  final int? durationSeconds;
  final String? durationFormatted;
  final String? reason;
  final TransportHaltLocation? location;
  final bool isAlertSent;

  TransportHalt({
    required this.id,
    this.bus,
    this.trip,
    this.startedAt,
    this.startedAtTime,
    this.endedAt,
    this.endedAtTime,
    this.isOngoing = false,
    this.durationSeconds,
    this.durationFormatted,
    this.reason,
    this.location,
    this.isAlertSent = false,
  });

  factory TransportHalt.fromJson(Map<String, dynamic> json) {
    return TransportHalt(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      bus: json['bus'] != null && json['bus'] is Map<String, dynamic>
          ? TransportHaltBus.fromJson(json['bus'])
          : null,
      trip: json['trip'] != null && json['trip'] is Map<String, dynamic>
          ? TransportHaltTrip.fromJson(json['trip'])
          : null,
      startedAt: json['started_at']?.toString(),
      startedAtTime: json['started_at_time']?.toString(),
      endedAt: json['ended_at']?.toString(),
      endedAtTime: json['ended_at_time']?.toString(),
      isOngoing: json['is_ongoing'] == true,
      durationSeconds: json['duration_seconds'] is int
          ? json['duration_seconds']
          : int.tryParse(json['duration_seconds']?.toString() ?? ''),
      durationFormatted: json['duration_formatted']?.toString(),
      reason: json['reason']?.toString(),
      location: json['location'] != null && json['location'] is Map<String, dynamic>
          ? TransportHaltLocation.fromJson(json['location'])
          : null,
      isAlertSent: json['is_alert_sent'] == true,
    );
  }
}

class TransportHaltBus {
  final int id;
  final String? busNumber;
  final String? plateNumber;

  TransportHaltBus({
    required this.id,
    this.busNumber,
    this.plateNumber,
  });

  factory TransportHaltBus.fromJson(Map<String, dynamic> json) {
    return TransportHaltBus(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      busNumber: (json['bus_number'] ?? json['bus_no'])?.toString(),
      plateNumber: (json['plate_number'] ?? json['vehicle_no'])?.toString(),
    );
  }
}

class TransportHaltTrip {
  final int id;
  final String? tripType;
  final String? routeName;
  final String? driverName;
  final String? driverPhone;

  TransportHaltTrip({
    required this.id,
    this.tripType,
    this.routeName,
    this.driverName,
    this.driverPhone,
  });

  factory TransportHaltTrip.fromJson(Map<String, dynamic> json) {
    return TransportHaltTrip(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      tripType: json['trip_type']?.toString(),
      routeName: (json['route_name'] ?? json['route'])?.toString(),
      driverName: json['driver_name']?.toString(),
      driverPhone: (json['driver_phone'] ?? json['phone'])?.toString(),
    );
  }
}

class TransportHaltLocation {
  final double? latitude;
  final double? longitude;
  final String? address;

  TransportHaltLocation({
    this.latitude,
    this.longitude,
    this.address,
  });

  factory TransportHaltLocation.fromJson(Map<String, dynamic> json) {
    return TransportHaltLocation(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address']?.toString(),
    );
  }
}
