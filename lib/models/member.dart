class Member {
  final String id;
  final String name;

  Member({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  factory Member.fromMap(Map<String, dynamic> map) => Member(id: map['id'], name: map['name']);
}
