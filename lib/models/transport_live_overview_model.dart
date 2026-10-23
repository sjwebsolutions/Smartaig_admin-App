class TransportLiveOverviewResponse {
  final bool success;
  final String? message;
  final TransportLiveOverviewData? data;

  TransportLiveOverviewResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory TransportLiveOverviewResponse.fromJson(Map<String, dynamic> json) {
    bool isSuccess = json['success'] ?? true;
    String? msg = json['message']?.toString();

    TransportLiveOverviewData? overviewData;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      overviewData = TransportLiveOverviewData.fromJson(json['data']);
    }

    return TransportLiveOverviewResponse(
      success: isSuccess,
      message: msg,
      data: overviewData,
    );
  }
}

class TransportLiveOverviewData {
  final TransportLiveSummary? summary;
  final List<TransportFleetItem> fleet;

  TransportLiveOverviewData({
    this.summary,
    required this.fleet,
  });

  factory TransportLiveOverviewData.fromJson(Map<String, dynamic> json) {
    List fleetList = json['fleet'] is List ? json['fleet'] : [];

    List<TransportFleetItem> parsedFleet = fleetList
        .whereType<Map<String, dynamic>>()
        .map((i) => TransportFleetItem.fromJson(i))
        .toList();

    TransportLiveSummary? summaryObj;
    if (json['summary'] != null && json['summary'] is Map<String, dynamic>) {
      summaryObj = TransportLiveSummary.fromJson(json['summary']);
    }

    return TransportLiveOverviewData(
      summary: summaryObj,
      fleet: parsedFleet,
    );
  }
}

class TransportLiveSummary {
  final int totalBuses;
  final int activeTrips;
  final int movingBuses;
  final int haltedBuses;
  final int signalLost;
  final int idleBuses;
  final int completedTripsToday;
  final int studentsOnBoard;
  final int unresolvedAlerts;
  final String? updatedAt;

  TransportLiveSummary({
    this.totalBuses = 0,
    this.activeTrips = 0,
    this.movingBuses = 0,
    this.haltedBuses = 0,
    this.signalLost = 0,
    this.idleBuses = 0,
    this.completedTripsToday = 0,
    this.studentsOnBoard = 0,
    this.unresolvedAlerts = 0,
    this.updatedAt,
  });

  factory TransportLiveSummary.fromJson(Map<String, dynamic> json) {
    return TransportLiveSummary(
      totalBuses: json['total_buses'] ?? 0,
      activeTrips: json['active_trips'] ?? 0,
      movingBuses: json['moving_buses'] ?? 0,
      haltedBuses: json['halted_buses'] ?? 0,
      signalLost: json['signal_lost'] ?? 0,
      idleBuses: json['idle_buses'] ?? 0,
      completedTripsToday: json['completed_trips_today'] ?? 0,
      studentsOnBoard: json['students_on_board'] ?? 0,
      unresolvedAlerts: json['unresolved_alerts'] ?? 0,
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class TransportFleetItem {
  final int busId;
  final String? busNumber;
  final String? plateNumber;
  final int? seatingCapacity;
  final String? vehicleStatus;
  final String? vehicleStatusText;
  final TransportAssignedRoute? assignedRoute;
  final TransportFleetDriver? driver;
  final TransportActiveTrip? activeTrip;

  TransportFleetItem({
    required this.busId,
    this.busNumber,
    this.plateNumber,
    this.seatingCapacity,
    this.vehicleStatus,
    this.vehicleStatusText,
    this.assignedRoute,
    this.driver,
    this.activeTrip,
  });

  factory TransportFleetItem.fromJson(Map<String, dynamic> json) {
    return TransportFleetItem(
      busId: json['bus_id'] is int ? json['bus_id'] : int.tryParse(json['bus_id']?.toString() ?? '0') ?? 0,
      busNumber: (json['bus_number'] ?? json['bus_no'])?.toString(),
      plateNumber: (json['plate_number'] ?? json['vehicle_no'])?.toString(),
      seatingCapacity: json['seating_capacity'] is int
          ? json['seating_capacity']
          : int.tryParse(json['seating_capacity']?.toString() ?? ''),
      vehicleStatus: json['vehicle_status']?.toString(),
      vehicleStatusText: (json['vehicle_status_text'] ?? json['status_text'])?.toString(),
      assignedRoute: json['assigned_route'] != null && json['assigned_route'] is Map<String, dynamic>
          ? TransportAssignedRoute.fromJson(json['assigned_route'])
          : null,
      driver: json['driver'] != null && json['driver'] is Map<String, dynamic>
          ? TransportFleetDriver.fromJson(json['driver'])
          : null,
      activeTrip: json['active_trip'] != null && json['active_trip'] is Map<String, dynamic>
          ? TransportActiveTrip.fromJson(json['active_trip'])
          : null,
    );
  }
}

class TransportAssignedRoute {
  final int id;
  final String? name;
  final String? code;

  TransportAssignedRoute({
    required this.id,
    this.name,
    this.code,
  });

  factory TransportAssignedRoute.fromJson(Map<String, dynamic> json) {
    return TransportAssignedRoute(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? json['route_name'])?.toString(),
      code: json['code']?.toString(),
    );
  }
}

class TransportFleetDriver {
  final int id;
  final String? name;
  final String? phone;
  final String? photo;

  TransportFleetDriver({
    required this.id,
    this.name,
    this.phone,
    this.photo,
  });

  factory TransportFleetDriver.fromJson(Map<String, dynamic> json) {
    return TransportFleetDriver(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      photo: json['photo']?.toString(),
    );
  }
}

class TransportActiveTrip {
  final int id;
  final String? tripType;
  final String? tripTypeLabel;
  final String? startedAt;
  final String? startedAtTime;
  final String? elapsedFormatted;
  final TransportTelemetry? telemetry;
  final TransportPassengerManifest? passengerManifest;
  final TransportActiveHalt? activeHalt;
  final int activeAlertsCount;

  TransportActiveTrip({
    required this.id,
    this.tripType,
    this.tripTypeLabel,
    this.startedAt,
    this.startedAtTime,
    this.elapsedFormatted,
    this.telemetry,
    this.passengerManifest,
    this.activeHalt,
    this.activeAlertsCount = 0,
  });

  factory TransportActiveTrip.fromJson(Map<String, dynamic> json) {
    return TransportActiveTrip(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      tripType: json['trip_type']?.toString(),
      tripTypeLabel: json['trip_type_label']?.toString(),
      startedAt: json['started_at']?.toString(),
      startedAtTime: json['started_at_time']?.toString(),
      elapsedFormatted: json['elapsed_formatted']?.toString(),
      telemetry: json['telemetry'] != null && json['telemetry'] is Map<String, dynamic>
          ? TransportTelemetry.fromJson(json['telemetry'])
          : null,
      passengerManifest: json['passenger_manifest'] != null && json['passenger_manifest'] is Map<String, dynamic>
          ? TransportPassengerManifest.fromJson(json['passenger_manifest'])
          : null,
      activeHalt: json['active_halt'] != null && json['active_halt'] is Map<String, dynamic>
          ? TransportActiveHalt.fromJson(json['active_halt'])
          : null,
      activeAlertsCount: json['active_alerts_count'] is int
          ? json['active_alerts_count']
          : int.tryParse(json['active_alerts_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class TransportTelemetry {
  final double? latitude;
  final double? longitude;
  final num? speed;
  final String? lastPingAt;
  final String? lastPingAgo;
  final bool isSignalLost;

  TransportTelemetry({
    this.latitude,
    this.longitude,
    this.speed,
    this.lastPingAt,
    this.lastPingAgo,
    this.isSignalLost = false,
  });

  factory TransportTelemetry.fromJson(Map<String, dynamic> json) {
    return TransportTelemetry(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      speed: json['speed'] as num?,
      lastPingAt: json['last_ping_at']?.toString(),
      lastPingAgo: json['last_ping_ago']?.toString(),
      isSignalLost: json['is_signal_lost'] == true,
    );
  }
}

class TransportPassengerManifest {
  final int totalAllocated;
  final int boarded;
  final int deboarded;
  final int absent;
  final num progressPercent;

  TransportPassengerManifest({
    this.totalAllocated = 0,
    this.boarded = 0,
    this.deboarded = 0,
    this.absent = 0,
    this.progressPercent = 0,
  });

  factory TransportPassengerManifest.fromJson(Map<String, dynamic> json) {
    return TransportPassengerManifest(
      totalAllocated: json['total_allocated'] ?? 0,
      boarded: json['boarded'] ?? 0,
      deboarded: json['deboarded'] ?? 0,
      absent: json['absent'] ?? 0,
      progressPercent: json['progress_percent'] is num
          ? json['progress_percent']
          : num.tryParse(json['progress_percent']?.toString() ?? '0') ?? 0,
    );
  }
}

class TransportActiveHalt {
  final int id;
  final String? reason;
  final String? startedAt;
  final String? durationText;

  TransportActiveHalt({
    required this.id,
    this.reason,
    this.startedAt,
    this.durationText,
  });

  factory TransportActiveHalt.fromJson(Map<String, dynamic> json) {
    return TransportActiveHalt(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      reason: json['reason']?.toString(),
      startedAt: json['started_at']?.toString(),
      durationText: (json['duration_text'] ?? json['duration_formatted'])?.toString(),
    );
  }
}
