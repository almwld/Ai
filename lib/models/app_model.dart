class AppModel {
  final String name;
  final String packageName;
  final String? iconBase64;
  final bool isSystemApp;
  final DateTime? installDate;
  final int? versionCode;
  final String? versionName;
  
  AppModel({
    required this.name,
    required this.packageName,
    this.iconBase64,
    this.isSystemApp = false,
    this.installDate,
    this.versionCode,
    this.versionName,
  });
  
  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      name: json['name'] ?? '',
      packageName: json['packageName'] ?? '',
      iconBase64: json['icon'],
      isSystemApp: json['isSystemApp'] ?? false,
      installDate: json['installDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['installDate']) 
          : null,
      versionCode: json['versionCode'],
      versionName: json['versionName'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'packageName': packageName,
      'icon': iconBase64,
      'isSystemApp': isSystemApp,
      'installDate': installDate?.millisecondsSinceEpoch,
      'versionCode': versionCode,
      'versionName': versionName,
    };
  }
  
  AppModel copyWith({
    String? name,
    String? packageName,
    String? iconBase64,
    bool? isSystemApp,
    DateTime? installDate,
    int? versionCode,
    String? versionName,
  }) {
    return AppModel(
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      iconBase64: iconBase64 ?? this.iconBase64,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      installDate: installDate ?? this.installDate,
      versionCode: versionCode ?? this.versionCode,
      versionName: versionName ?? this.versionName,
    );
  }
  
  @override
  String toString() => 'AppModel(name: $name, packageName: $packageName)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppModel && other.packageName == packageName;
  }
  
  @override
  int get hashCode => packageName.hashCode;
}
