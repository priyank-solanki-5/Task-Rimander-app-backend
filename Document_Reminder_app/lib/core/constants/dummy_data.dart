class Member {
  final String id;
  final String name;
  final String relation;
  final int documentCount;

  Member({
    required this.id,
    required this.name,
    required this.relation,
    this.documentCount = 0,
  });
}

class Task {
  final String id;
  final String memberId;
  final String memberName;
  final String title;
  final String description;
  final String documentType;
  final DateTime dueDate;
  final int reminderDays;
  final bool isCompleted;

  Task({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.title,
    required this.description,
    required this.documentType,
    required this.dueDate,
    required this.reminderDays,
    this.isCompleted = false,
  });

  bool get isDue {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference <= 0;
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference > 0 && difference <= reminderDays;
  }
}

class DummyData {
  static final List<Member> members = [
    Member(id: '1', name: 'Self', relation: 'Self', documentCount: 5),
    Member(id: '2', name: 'Father', relation: 'Father', documentCount: 3),
    Member(id: '3', name: 'Mother', relation: 'Mother', documentCount: 2),
    Member(id: '4', name: 'Business', relation: 'Business', documentCount: 8),
  ];

  static final List<Task> tasks = [
    Task(
      id: '1',
      memberId: '1',
      memberName: 'Self',
      title: 'Passport Renewal',
      description: 'Passport expires soon, need to renew',
      documentType: 'Passport',
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      reminderDays: 30,
    ),
    Task(
      id: '2',
      memberId: '1',
      memberName: 'Self',
      title: 'Driving License Renewal',
      description: 'DL renewal required',
      documentType: 'Driving License',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      reminderDays: 15,
    ),
    Task(
      id: '3',
      memberId: '2',
      memberName: 'Father',
      title: 'Health Insurance Renewal',
      description: 'Annual health insurance renewal',
      documentType: 'Insurance Policy',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      reminderDays: 30,
    ),
    Task(
      id: '4',
      memberId: '4',
      memberName: 'Business',
      title: 'GST Filing',
      description: 'Quarterly GST filing deadline',
      documentType: 'Bank Documents',
      dueDate: DateTime.now().add(const Duration(days: 10)),
      reminderDays: 7,
    ),
    Task(
      id: '5',
      memberId: '3',
      memberName: 'Mother',
      title: 'PAN Card Update',
      description: 'Update address in PAN card',
      documentType: 'PAN Card',
      dueDate: DateTime.now().add(const Duration(days: 20)),
      reminderDays: 15,
    ),
  ];

  static String userName = 'Shrey';
  static String userEmail = 'shrey@example.com';
  static String userMobile = '+91 9876543210';
}
