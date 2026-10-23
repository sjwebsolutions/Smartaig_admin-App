class TransportLocationRequestsResponse {
  final bool success;
  final String? message;
  final TransportLocationData? data;

  TransportLocationRequestsResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory TransportLocationRequestsResponse.fromJson(Map<String, dynamic> json) {
    bool isSuccess = json['success'] ?? true;
    String? msg = json['message']?.toString();

    TransportLocationData? locationData;
    if (json['data'] != null) {
      locationData = TransportLocationData.fromJson(json['data']);
    } else if (json['requests'] != null) {
      locationData = TransportLocationData.fromJson(json);
    }

    return TransportLocationRequestsResponse(
      success: isSuccess,
      message: msg,
      data: locationData,
    );
  }
}

class TransportLocationData {
  final TransportSummary? summary;
  final List<TransportLocationRequest> requests;
  final PaginationInfo? pagination;

  TransportLocationData({
    this.summary,
    required this.requests,
    this.pagination,
  });

  factory TransportLocationData.fromJson(dynamic json) {
    if (json == null) {
      return TransportLocationData(requests: []);
    }

    if (json is List) {
      List<TransportLocationRequest> parsedRequests = json
          .whereType<Map<String, dynamic>>()
          .map((i) => TransportLocationRequest.fromJson(i))
          .toList();

      return TransportLocationData(
        summary: TransportSummary(
          total: parsedRequests.length,
          pending: parsedRequests.where((r) => r.status.toLowerCase() == 'pending').length,
          approved: parsedRequests.where((r) => r.status.toLowerCase() == 'approved').length,
          rejected: parsedRequests.where((r) => r.status.toLowerCase() == 'rejected').length,
        ),
        requests: parsedRequests,
      );
    }

    if (json is Map<String, dynamic>) {
      List reqList = [];

      if (json['requests'] is List) {
        reqList = json['requests'];
      } else if (json['data'] is List) {
        reqList = json['data'];
      } else if (json['requests'] is Map && json['requests']['data'] is List) {
        reqList = json['requests']['data'];
      } else if (json.containsKey('id')) {
        reqList = [json];
      }

      List<TransportLocationRequest> parsedRequests = reqList
          .whereType<Map<String, dynamic>>()
          .map((i) => TransportLocationRequest.fromJson(i))
          .toList();

      TransportSummary? summary;
      if (json['summary'] != null && json['summary'] is Map<String, dynamic>) {
        summary = TransportSummary.fromJson(json['summary']);
      } else {
        summary = TransportSummary(
          total: json['total'] is int ? json['total'] : parsedRequests.length,
          pending: json['pending'] is int
              ? json['pending']
              : parsedRequests.where((r) => r.status.toLowerCase() == 'pending').length,
          approved: json['approved'] is int
              ? json['approved']
              : parsedRequests.where((r) => r.status.toLowerCase() == 'approved').length,
          rejected: json['rejected'] is int
              ? json['rejected']
              : parsedRequests.where((r) => r.status.toLowerCase() == 'rejected').length,
        );
      }

      PaginationInfo? pagination;
      if (json['pagination'] != null && json['pagination'] is Map<String, dynamic>) {
        pagination = PaginationInfo.fromJson(json['pagination']);
      }

      return TransportLocationData(
        summary: summary,
        requests: parsedRequests,
        pagination: pagination,
      );
    }

    return TransportLocationData(requests: []);
  }
}

class TransportSummary {
  final int total;
  final int pending;
  final int approved;
  final int rejected;

  TransportSummary({
    this.total = 0,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
  });

  factory TransportSummary.fromJson(Map<String, dynamic> json) {
    return TransportSummary(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }
}

class TransportLocationRequest {
  final int id;
  final String status;
  final String statusLabel;
  final String? requestedVia;
  final String? requestedByName;
  final String? requestedByRole;
  final String? requestedAt;
  final String? requestedAtTime;
  final String? locationType;
  final String? addressNotes;
  final StudentDetail? student;
  final TransportInfo? transport;
  final CoordinatesInfo? oldCoordinates;
  final CoordinatesInfo? proposedCoordinates;
  final AuditInfo? audit;

  TransportLocationRequest({
    required this.id,
    required this.status,
    required this.statusLabel,
    this.requestedVia,
    this.requestedByName,
    this.requestedByRole,
    this.requestedAt,
    this.requestedAtTime,
    this.locationType,
    this.addressNotes,
    this.student,
    this.transport,
    this.oldCoordinates,
    this.proposedCoordinates,
    this.audit,
  });

  factory TransportLocationRequest.fromJson(Map<String, dynamic> json) {
    String? rawReqAtTime = json['requested_at_time'];
    if ((rawReqAtTime == null || rawReqAtTime.isEmpty) && json['requested_at'] != null) {
      rawReqAtTime = _formatDateTime(json['requested_at'].toString());
    }

    // Student object fallback from top level
    StudentDetail? studentObj;
    if (json['student'] != null && json['student'] is Map<String, dynamic>) {
      studentObj = StudentDetail.fromJson(json['student']);
    } else if (json['student_name'] != null || json['student_id'] != null) {
      studentObj = StudentDetail.fromJson(json);
    }

    // Transport object fallback from top level
    TransportInfo? transportObj;
    if (json['transport'] != null && json['transport'] is Map<String, dynamic>) {
      transportObj = TransportInfo.fromJson(json['transport']);
    } else if (json['bus_number'] != null || json['route_name'] != null) {
      transportObj = TransportInfo.fromJson(json);
    }

    // Old Coordinates fallback
    CoordinatesInfo? oldCoordsObj;
    if (json['old_coordinates'] != null && json['old_coordinates'] is Map<String, dynamic>) {
      oldCoordsObj = CoordinatesInfo.fromJson(json['old_coordinates']);
    } else if (json['old_address'] != null || json['current_address'] != null) {
      oldCoordsObj = CoordinatesInfo(
        address: (json['old_address'] ?? json['current_address'])?.toString(),
      );
    }

    // Proposed Coordinates fallback
    CoordinatesInfo? propCoordsObj;
    if (json['proposed_coordinates'] != null && json['proposed_coordinates'] is Map<String, dynamic>) {
      propCoordsObj = CoordinatesInfo.fromJson(json['proposed_coordinates']);
    } else if (json['proposed_address'] != null || json['new_address'] != null) {
      propCoordsObj = CoordinatesInfo(
        address: (json['proposed_address'] ?? json['new_address'])?.toString(),
        notes: (json['address_notes'] ?? json['notes'])?.toString(),
      );
    }

    AuditInfo? parsedAudit;
    if (json['audit'] != null && json['audit'] is Map<String, dynamic>) {
      parsedAudit = AuditInfo.fromJson(json['audit']);
    } else if (json['action_by_name'] != null ||
        json['approved_by'] != null ||
        json['rejected_by'] != null ||
        json['rejection_reason'] != null ||
        json['reason'] != null ||
        json['action_at'] != null ||
        json['approved_at'] != null ||
        json['rejected_at'] != null) {
      parsedAudit = AuditInfo.fromJson(json);
    }

    return TransportLocationRequest(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      status: (json['status'] ?? '').toString(),
      statusLabel: (json['status_label'] ?? json['status'] ?? '').toString(),
      requestedVia: json['requested_via']?.toString(),
      requestedByName: (json['requested_by_name'] ?? json['requested_by'] ?? json['parent_name'])?.toString(),
      requestedByRole: json['requested_by_role']?.toString(),
      requestedAt: json['requested_at']?.toString(),
      requestedAtTime: rawReqAtTime,
      locationType: json['location_type']?.toString(),
      addressNotes: (json['address_notes'] ?? json['notes'])?.toString(),
      student: studentObj,
      transport: transportObj,
      oldCoordinates: oldCoordsObj,
      proposedCoordinates: propCoordsObj,
      audit: parsedAudit,
    );
  }

  static String? _formatDateTime(String raw) {
    if (raw.isEmpty) return null;
    try {
      DateTime dt = DateTime.parse(raw);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }
}

class StudentDetail {
  final int id;
  final String? uniqueId;
  final String name;
  final String? className;
  final String? sectionName;
  final String? parentPhone;

  StudentDetail({
    required this.id,
    this.uniqueId,
    required this.name,
    this.className,
    this.sectionName,
    this.parentPhone,
  });

  factory StudentDetail.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return StudentDetail(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        uniqueId: (json['unique_id'] ?? json['student_unique_id'] ?? json['admission_no'] ?? json['roll_no'])?.toString(),
        name: (json['name'] ?? json['student_name'] ?? json['full_name'] ?? '')?.toString() ?? '',
        className: (json['class_name'] ?? json['class'] ?? json['course_name'])?.toString(),
        sectionName: (json['section_name'] ?? json['section'])?.toString(),
        parentPhone: (json['parent_phone'] ?? json['phone'] ?? json['mobile'] ?? json['contact'])?.toString(),
      );
    }
    return StudentDetail(id: 0, name: '');
  }
}

class TransportInfo {
  final String? busNumber;
  final String? routeName;
  final String? stoppageName;

  TransportInfo({
    this.busNumber,
    this.routeName,
    this.stoppageName,
  });

  factory TransportInfo.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return TransportInfo(
        busNumber: (json['bus_number'] ?? json['bus_no'] ?? json['vehicle_number'])?.toString(),
        routeName: (json['route_name'] ?? json['route'])?.toString(),
        stoppageName: (json['stoppage_name'] ?? json['stoppage'] ?? json['stop_name'])?.toString(),
      );
    }
    return TransportInfo();
  }
}

class CoordinatesInfo {
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropLatitude;
  final double? dropLongitude;
  final String? address;
  final String? notes;

  CoordinatesInfo({
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropLatitude,
    this.dropLongitude,
    this.address,
    this.notes,
  });

  factory CoordinatesInfo.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return CoordinatesInfo(
        pickupLatitude: (json['pickup_latitude'] ?? json['latitude'] ?? json['lat'] as num?)?.toDouble(),
        pickupLongitude: (json['pickup_longitude'] ?? json['longitude'] ?? json['lng'] as num?)?.toDouble(),
        dropLatitude: (json['drop_latitude'] as num?)?.toDouble(),
        dropLongitude: (json['drop_longitude'] as num?)?.toDouble(),
        address: (json['address'] ?? json['location'] ?? json['address_text'])?.toString(),
        notes: (json['notes'] ?? json['address_notes'] ?? json['remark'])?.toString(),
      );
    }
    return CoordinatesInfo();
  }
}

class AuditInfo {
  final int? actionById;
  final String? actionByName;
  final String? actionByRole;
  final String? actionVia;
  final String? actionViaLabel;
  final String? actionAt;
  final String? rejectionReason;

  AuditInfo({
    this.actionById,
    this.actionByName,
    this.actionByRole,
    this.actionVia,
    this.actionViaLabel,
    this.actionAt,
    this.rejectionReason,
  });

  factory AuditInfo.fromJson(Map<String, dynamic> json) {
    return AuditInfo(
      actionById: json['action_by_id'] is int
          ? json['action_by_id']
          : int.tryParse(json['action_by_id']?.toString() ?? ''),
      actionByName: (json['action_by_name'] ?? json['approved_by'] ?? json['rejected_by'])?.toString(),
      actionByRole: json['action_by_role']?.toString(),
      actionVia: json['action_via']?.toString(),
      actionViaLabel: (json['action_via_label'] ?? json['action_via'])?.toString(),
      actionAt: (json['action_at'] ?? json['approved_at'] ?? json['rejected_at'])?.toString(),
      rejectionReason: (json['rejection_reason'] ?? json['reason'])?.toString(),
    );
  }
}

class PaginationInfo {
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;

  PaginationInfo({
    this.total = 0,
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
    );
  }
}
