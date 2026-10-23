import 'package:smart_aig_admins_app/models/transport_location_requests_model.dart';

class TransportAlertsResponse {
  final bool success;
  final String? message;
  final TransportAlertsData? data;

  TransportAlertsResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory TransportAlertsResponse.fromJson(Map<String, dynamic> json) {
    bool isSuccess = json['success'] ?? true;
    String? msg = json['message']?.toString();

    TransportAlertsData? alertsData;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      alertsData = TransportAlertsData.fromJson(json['data']);
    } else if (json['alerts'] != null) {
      alertsData = TransportAlertsData.fromJson(json);
    }

    return TransportAlertsResponse(
      success: isSuccess,
      message: msg,
      data: alertsData,
    );
  }
}

class TransportAlertsData {
  final List<TransportAlert> alerts;
  final PaginationInfo? pagination;

  TransportAlertsData({
    required this.alerts,
    this.pagination,
  });

  factory TransportAlertsData.fromJson(Map<String, dynamic> json) {
    List alertsList = [];
    if (json['alerts'] is List) {
      alertsList = json['alerts'];
    } else if (json['data'] is List) {
      alertsList = json['data'];
    }

    List<TransportAlert> parsedAlerts = alertsList
        .whereType<Map<String, dynamic>>()
        .map((i) => TransportAlert.fromJson(i))
        .toList();

    PaginationInfo? pagination;
    if (json['pagination'] != null && json['pagination'] is Map<String, dynamic>) {
      pagination = PaginationInfo.fromJson(json['pagination']);
    }

    return TransportAlertsData(
      alerts: parsedAlerts,
      pagination: pagination,
    );
  }
}

class TransportAlert {
  final int id;
  final String? alertType;
  final String? alertTypeLabel;
  final String? severity;
  final String? title;
  final String? message;
  final int? delayMinutes;
  final TransportAlertBus? bus;
  final TransportAlertRoute? route;
  final TransportAlertPerson? driver;
  final TransportAlertPerson? reportedBy;
  final TransportAlertLocation? location;
  final bool isResolved;
  final String? resolvedAt;
  final String? resolvedByName;
  final String? resolutionNotes;
  final TransportParentBroadcast? parentBroadcast;
  final String? createdAt;
  final String? createdAtTime;
  final String? createdAtAgo;

  TransportAlert({
    required this.id,
    this.alertType,
    this.alertTypeLabel,
    this.severity,
    this.title,
    this.message,
    this.delayMinutes,
    this.bus,
    this.route,
    this.driver,
    this.reportedBy,
    this.location,
    this.isResolved = false,
    this.resolvedAt,
    this.resolvedByName,
    this.resolutionNotes,
    this.parentBroadcast,
    this.createdAt,
    this.createdAtTime,
    this.createdAtAgo,
  });

  factory TransportAlert.fromJson(Map<String, dynamic> json) {
    return TransportAlert(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      alertType: json['alert_type']?.toString(),
      alertTypeLabel: json['alert_type_label']?.toString(),
      severity: json['severity']?.toString(),
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      delayMinutes: json['delay_minutes'] is int
          ? json['delay_minutes']
          : int.tryParse(json['delay_minutes']?.toString() ?? ''),
      bus: json['bus'] != null && json['bus'] is Map<String, dynamic>
          ? TransportAlertBus.fromJson(json['bus'])
          : null,
      route: json['route'] != null && json['route'] is Map<String, dynamic>
          ? TransportAlertRoute.fromJson(json['route'])
          : null,
      driver: json['driver'] != null && json['driver'] is Map<String, dynamic>
          ? TransportAlertPerson.fromJson(json['driver'])
          : null,
      reportedBy: json['reported_by'] != null && json['reported_by'] is Map<String, dynamic>
          ? TransportAlertPerson.fromJson(json['reported_by'])
          : null,
      location: json['location'] != null && json['location'] is Map<String, dynamic>
          ? TransportAlertLocation.fromJson(json['location'])
          : null,
      isResolved: json['is_resolved'] == true,
      resolvedAt: json['resolved_at']?.toString(),
      resolvedByName: (json['resolved_by_name'] ?? json['resolved_by'])?.toString(),
      resolutionNotes: json['resolution_notes']?.toString(),
      parentBroadcast: json['parent_broadcast'] != null && json['parent_broadcast'] is Map<String, dynamic>
          ? TransportParentBroadcast.fromJson(json['parent_broadcast'])
          : null,
      createdAt: json['created_at']?.toString(),
      createdAtTime: json['created_at_time']?.toString(),
      createdAtAgo: json['created_at_ago']?.toString(),
    );
  }
}

class TransportAlertBus {
  final int id;
  final String? busNumber;
  final String? plateNumber;

  TransportAlertBus({
    required this.id,
    this.busNumber,
    this.plateNumber,
  });

  factory TransportAlertBus.fromJson(Map<String, dynamic> json) {
    return TransportAlertBus(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      busNumber: (json['bus_number'] ?? json['bus_no'])?.toString(),
      plateNumber: (json['plate_number'] ?? json['vehicle_no'])?.toString(),
    );
  }
}

class TransportAlertRoute {
  final int id;
  final String? name;

  TransportAlertRoute({
    required this.id,
    this.name,
  });

  factory TransportAlertRoute.fromJson(Map<String, dynamic> json) {
    return TransportAlertRoute(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? json['route_name'])?.toString(),
    );
  }
}

class TransportAlertPerson {
  final int id;
  final String? name;
  final String? phone;
  final String? role;

  TransportAlertPerson({
    required this.id,
    this.name,
    this.phone,
    this.role,
  });

  factory TransportAlertPerson.fromJson(Map<String, dynamic> json) {
    return TransportAlertPerson(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? json['full_name'])?.toString(),
      phone: (json['phone'] ?? json['mobile'])?.toString(),
      role: json['role']?.toString(),
    );
  }
}

class TransportAlertLocation {
  final double? latitude;
  final double? longitude;
  final String? locationName;

  TransportAlertLocation({
    this.latitude,
    this.longitude,
    this.locationName,
  });

  factory TransportAlertLocation.fromJson(Map<String, dynamic> json) {
    return TransportAlertLocation(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: (json['location_name'] ?? json['address'])?.toString(),
    );
  }
}

class TransportParentBroadcast {
  final bool sent;
  final String? sentAt;
  final int parentsCount;
  final String? broadcastMessage;

  TransportParentBroadcast({
    this.sent = false,
    this.sentAt,
    this.parentsCount = 0,
    this.broadcastMessage,
  });

  factory TransportParentBroadcast.fromJson(Map<String, dynamic> json) {
    return TransportParentBroadcast(
      sent: json['sent'] == true,
      sentAt: json['sent_at']?.toString(),
      parentsCount: json['parents_count'] is int
          ? json['parents_count']
          : int.tryParse(json['parents_count']?.toString() ?? '0') ?? 0,
      broadcastMessage: json['broadcast_message']?.toString(),
    );
  }
}
