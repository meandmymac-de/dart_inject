# dart_inject

A very simple and easy to use dependency injection framework for Dart.

## Usage

A simple usage example:

```dart
import 'package:dart_inject/dart_inject.dart' as di;

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
  di.startup(() {
    di.register<Vehicle>(() => Car('BMW X6'));
  });

  var car = di.resolve<Vehicle>();
  var carName = car.name;
  print('I own a $carName');
}

```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/meandmymac-de/dart_inject/issues
