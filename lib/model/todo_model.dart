class TodoModel {
  final String id;
  final String title;
  final bool isChecked;

  TodoModel({required this.id, required this.title, required this.isChecked});

  factory TodoModel.fromMap(Map<String, dynamic> data, String docId) {
    return TodoModel(
      id: docId,
      title: data['title'],
      isChecked: data['isChecked'],
    );
  }
}
