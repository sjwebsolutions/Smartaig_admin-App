class DeadlinesModel {
  bool? success;
  List<Deadline>? data;

  DeadlinesModel({this.success, this.data});

  DeadlinesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Deadline>[];
      json['data'].forEach((v) {
        data!.add(Deadline.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Deadline {
  int? id;
  String? name;
  String? link;
  String? proformaName;
  String? dateOfOpening;
  String? dateOfSubmission;
  String? formattedDateOfSubmission;
  int? lateFee;
  String? docLink;
  String? boardType;
  String? remarks;
  int? daysRemaining;

  Deadline(
      {this.id,
      this.name,
      this.link,
      this.proformaName,
      this.dateOfOpening,
      this.dateOfSubmission,
      this.formattedDateOfSubmission,
      this.lateFee,
      this.docLink,
      this.boardType,
      this.remarks,
      this.daysRemaining});

  Deadline.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    link = json['link'];
    proformaName = json['proforma_name'];
    dateOfOpening = json['date_of_opening'];
    dateOfSubmission = json['date_of_submission'];
    formattedDateOfSubmission = json['formatted_date_of_submission'];
    lateFee = json['late_fee'];
    docLink = json['doc_link'];
    boardType = json['board_type'];
    remarks = json['remarks'];
    daysRemaining = json['days_remaining'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['link'] = link;
    data['proforma_name'] = proformaName;
    data['date_of_opening'] = dateOfOpening;
    data['date_of_submission'] = dateOfSubmission;
    data['formatted_date_of_submission'] = formattedDateOfSubmission;
    data['late_fee'] = lateFee;
    data['doc_link'] = docLink;
    data['board_type'] = boardType;
    data['remarks'] = remarks;
    data['days_remaining'] = daysRemaining;
    return data;
  }
}
