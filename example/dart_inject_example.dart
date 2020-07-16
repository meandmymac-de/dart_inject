import 'package:dart_inject/dart_inject.dart';

abstract class Vehicle {
  String get name;
}

class Car implements Vehicle {
  String _name;

  @override
  String get name => _name;

  Car(String name) {
    _name = name;
  }
}

void main() {
  InjectionContext().startup((context) {
    register<Vehicle>(() => Car('BMW X6'));
  });

  var car = resolve<Vehicle>(); 
  var carName = car.name;
  print('I own a $carName');
}
