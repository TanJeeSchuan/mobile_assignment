class UserData {
  final String id;
  final String staffId;
  final String staffName;
  final String contactNumber;
  final String staffEmail;

  const UserData({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.contactNumber,
    required this.staffEmail,
  });

  factory UserData.fromFirestore(String id, Map<String, dynamic> data) {
    return UserData(
      id: id,
      staffId: data["StaffID"]?.toString() ?? "",   // 🔥 convert to String
      staffName: data["StaffName"] ?? "",
      contactNumber: data["StaffContact"] ?? "",
      staffEmail: data["StaffEmail"] ?? "",
    );
  }

  // Factory constructor for JSON map (from HTTP or Firestore-like map with 'id' inside)
  /// From JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? "",
      staffId: json['StaffID']?.toString() ?? "",
      staffName: json['StaffName'] ?? "",
      contactNumber: json['StaffContact'] ?? "",
      staffEmail: json['StaffEmail'] ?? "",
    );
  }
}