// lib/data/student_data.dart

import 'package:eskool/models/Students_model.dart';
// import 'package:eskool/models/student.dart';

final Map<String, List<Student>> classWiseStudents = {
  'Class 1': [
    Student(
        name: "John Doe",
        rollNo: "1",
        grade: "A",
        parentName: "Jane Doe",
        className: 'Class 1'),
    Student(
        name: "Emma Watson",
        rollNo: "2",
        grade: "B",
        parentName: "Richard Watson",
        className: 'Class 1'),
  ],
  'Class 2': [
    Student(
        name: "Chris Evans",
        rollNo: "3",
        grade: "A",
        parentName: "Lisa Evans",
        className: 'Class 2'),
    Student(
        name: "Scarlett Johansson",
        rollNo: "4",
        grade: "B",
        parentName: "Paul Johansson",
        className: 'Class 2'),
  ],
  // Add more classes and students here...
};