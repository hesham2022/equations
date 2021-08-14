import 'dart:convert';

class Equation {
  final int firstOpeartor;
  final int secondOpeartor;
  final String opeartor;
  final DateTime time;
  bool completed;
  int get result {
    if (opeartor == '-') {
      return firstOpeartor - secondOpeartor;
    }
    if (opeartor == '+') {
      return firstOpeartor + secondOpeartor;
    }
    return 0;
  }

  Equation({
    required this.firstOpeartor,
    required this.secondOpeartor,
    required this.opeartor,
    required this.time,
    this.completed = false
  });

  Equation copyWith({
    int? firstOpeartor,
    int? secondOpeartor,
    String? opeartor,
    DateTime? time,
    bool? completed,
  }) {
    return Equation(
      firstOpeartor: firstOpeartor ?? this.firstOpeartor,
      secondOpeartor: secondOpeartor ?? this.secondOpeartor,
      opeartor: opeartor ?? this.opeartor,
      time: time ?? this.time,
      completed: completed??this.completed
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstOpeartor': firstOpeartor,
      'secondOpeartor': secondOpeartor,
      'opeartor': opeartor,
      'time': time.millisecondsSinceEpoch,
      'completed': completed,
    };
  }

  factory Equation.fromMap(Map<String, dynamic> map) {
    return Equation(
      firstOpeartor: map['firstOpeartor'],
      secondOpeartor: map['secondOpeartor'],
      opeartor: map['opeartor'],
      completed: map['completed'],
      time: DateTime.fromMillisecondsSinceEpoch(map['time']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Equation.fromJson(String source) =>
      Equation.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Equation(firstOpeartor: $firstOpeartor, secondOpeartor: $secondOpeartor, opeartor: $opeartor, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Equation &&
        other.firstOpeartor == firstOpeartor &&
        other.secondOpeartor == secondOpeartor &&
        other.opeartor == opeartor &&
        other.completed == completed &&
        other.time == time;
  }

  @override
  int get hashCode {
    return firstOpeartor.hashCode ^
        secondOpeartor.hashCode ^
        completed.hashCode ^
        opeartor.hashCode ^
        time.hashCode;
  }
}
