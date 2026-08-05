/// EDINET開示文書から抽出したテキスト（Gemini分析用）
class DisclosureTextExtract {
  final String code;
  final String docId;
  final String sectionName;
  final String text;

  const DisclosureTextExtract({
    required this.code,
    required this.docId,
    required this.sectionName,
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'docId': docId,
      'sectionName': sectionName,
      'text': text,
    };
  }
}
