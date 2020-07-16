# dart_inject ![Build Result](https://travis-ci.org/meandmymac-de/dart_inject.svg?branch=master)

A very simple and easy to use dependency injection framework for Dart.

## Usage

A simple usage example:

```dart
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

```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/meandmymac-de/dart_inject/issues
