/// EDINET書類モデル
class EdinetDocument {
  final String docId;
  final String? edinetCode;
  final String? secCode;
  final String filerName;
  final String docTypeCode;
  final String docDescription;
  final DateTime submitDateTime;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  const EdinetDocument({
    required this.docId,
    this.edinetCode,
    this.secCode,
    required this.filerName,
    required this.docTypeCode,
    required this.docDescription,
    required this.submitDateTime,
    this.periodStart,
    this.periodEnd,
  });

  factory EdinetDocument.fromJson(Map<String, dynamic> json) {
    return EdinetDocument(
      docId: json['docID']?.toString() ?? '',
      edinetCode: json['edinetCode']?.toString(),
      secCode: json['secCode']?.toString(),
      filerName: json['filerName']?.toString() ?? '',
      docTypeCode: json['docTypeCode']?.toString() ?? '',
      docDescription: json['docDescription']?.toString() ?? '',
      submitDateTime: DateTime.tryParse(json['submitDateTime']?.toString() ?? '') ?? DateTime.now(),
      periodStart: json['periodStart'] != null ? DateTime.tryParse(json['periodStart'].toString()) : null,
      periodEnd: json['periodEnd'] != null ? DateTime.tryParse(json['periodEnd'].toString()) : null,
    );
  }

  /// 有価証券報告書かどうか
  bool get isAnnualReport => docTypeCode == '120';

  /// 四半期報告書かどうか
  bool get isQuarterlyReport => docTypeCode == '140';

  /// 半期報告書かどうか
  bool get isSemiAnnualReport => docTypeCode == '160';

  /// 訂正報告書かどうか
  bool get isAmendment =>
      docTypeCode == '130' || docTypeCode == '150' || docTypeCode == '170';

  /// 人が読みやすい書類種別名
  String get docTypeName {
    switch (docTypeCode) {
      case '120':
        return '有価証券報告書';
      case '130':
        return '有価証券報告書（訂正）';
      case '140':
        return '四半期報告書';
      case '150':
        return '四半期報告書（訂正）';
      case '160':
        return '半期報告書';
      case '170':
        return '半期報告書（訂正）';
      default:
        return 'その他 ($docTypeCode)';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'docID': docId,
      'edinetCode': edinetCode,
      'secCode': secCode,
      'filerName': filerName,
      'docTypeCode': docTypeCode,
      'docDescription': docDescription,
      'submitDateTime': submitDateTime.toIso8601String(),
      'periodStart': periodStart?.toIso8601String(),
      'periodEnd': periodEnd?.toIso8601String(),
    };
  }
}
