class AppConstants {
  // Dropdown options
  static const List<String> relations = [
    'Self',
    'Father',
    'Mother',
    'Spouse',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Business',
    'Other',
  ];

  static const List<String> documentTypes = [
    'Driving License',
    'Passport',
    'Aadhaar Card',
    'PAN Card',
    'Voter ID',
    '10th Marksheet',
    '12th Marksheet',
    'Degree Certificate',
    'Life Insurance',
    'Health Insurance',
    'Vehicle Registration',
    'Property Documents',
    'Bank Documents',
    'Medical Records',
    'Other',
  ];

  static const List<int> reminderDays = [1, 3, 7, 15, 30, 60, 90];

  // App strings
  static const String appName = 'Document Reminder';
  static const String appTagline = 'Never miss a document renewal';
}
