class ContactModel {
  final String id;
  final String name;
  final List<String> phoneNumbers;
  final List<String> emails;
  final String? photoUri;
  final String? company;
  final String? jobTitle;
  final String? note;
  
  ContactModel({
    required this.id,
    required this.name,
    this.phoneNumbers = const [],
    this.emails = const [],
    this.photoUri,
    this.company,
    this.jobTitle,
    this.note,
  });
  
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumbers: List<String>.from(json['phoneNumbers'] ?? []),
      emails: List<String>.from(json['emails'] ?? []),
      photoUri: json['photoUri'],
      company: json['company'],
      jobTitle: json['jobTitle'],
      note: json['note'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumbers': phoneNumbers,
      'emails': emails,
      'photoUri': photoUri,
      'company': company,
      'jobTitle': jobTitle,
      'note': note,
    };
  }
  
  String get primaryPhoneNumber => phoneNumbers.isNotEmpty ? phoneNumbers.first : '';
  String get primaryEmail => emails.isNotEmpty ? emails.first : '';
  
  ContactModel copyWith({
    String? id,
    String? name,
    List<String>? phoneNumbers,
    List<String>? emails,
    String? photoUri,
    String? company,
    String? jobTitle,
    String? note,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      emails: emails ?? this.emails,
      photoUri: photoUri ?? this.photoUri,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      note: note ?? this.note,
    );
  }
  
  @override
  String toString() => 'ContactModel(name: $name, phone: $primaryPhoneNumber)';
}
