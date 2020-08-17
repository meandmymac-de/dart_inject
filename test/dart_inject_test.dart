//
// Copyright 2020 Thomas Bonk <thomas@meandmymac.de>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import 'package:dart_inject/dart_inject.dart' as di;
import 'package:test/test.dart';

void main() {
  tearDown(() => di.shutdown());

  //
  // ***** Check initialization logic *****
  //
  group('Check initialization logic', () {
    test('Starting the injection context more than once is not possible', () {
      expect(() {
        di.startup((context) {});
        di.startup((context) {});
      }, throwsException);
    });
    test('Resolving without an initialized injection context is failing', () {
      expect(() => di.resolve<String>(), throwsException);
    });
  });
  //
  // ***** Registering an resolving services is successful *****
  //
  group('Registering and resolving services is successful', () {
    test('Resolving an unknown service is failing', () {
      di.startup((context) {});

      expect(() => di.resolve<String>(), throwsException);
    });
    test('Register a non-singleton service and resolving it, is successful', () {
      di.startup((context) {
        context.register<String>(() => 'Hello world!', asSingleton: false);
      });

      var service = di.resolve<String>();

      expect(service, equals('Hello world!'));
    });
    test('Register a non-singleton service creates new instances on resolution', () {
      var instNum = 0;
      di.startup((context) {
        context.register<String>(() {
          instNum++;
          return "I'm instance $instNum";
        }, asSingleton: false);
      });

      var service1 = di.resolve<String>();
      var service2 = di.resolve<String>();

      expect(service1, equals("I'm instance 1"));
      expect(service2, equals("I'm instance 2"));
      expect(identical(service1, service2), isFalse);
    });
    test('Register a singleton service returns the same instances on resolution', () {
      var instNum = 0;
      di.startup((context) {
        context.register<String>(() {
          instNum++;
          return "I'm instance $instNum";
        }, asSingleton: true);
      });

      var service1 = di.resolve<String>();
      var service2 = di.resolve<String>();

      expect(service1, equals("I'm instance 1"));
      expect(service2, equals("I'm instance 1"));
      expect(identical(service1, service2), isTrue);
    });
    test('Registering services with same type and different names and resolving them is successful', () {
      di.startup((context) {
        context.register<String>(() => "I'm a Cat", name: 'Cat', asSingleton: false);
        context.register<String>(() => "I'm a Dog", name: 'Dog', asSingleton: false);
      });

      var cat = di.resolve<String>(name: 'Cat');
      var dog = di.resolve<String>(name: 'Dog');

      expect(cat, equals("I'm a Cat"));
      expect(dog, equals("I'm a Dog"));
    });
    test('Registering two services with same type and names is not successful', () {
      expect(
          () => di.startup((context) {
                context.register<String>(() => "I'm a Cat", name: 'Pet', asSingleton: false);
                context.register<String>(() => "I'm a Dog", name: 'Pet', asSingleton: false);
              }),
          throwsException);
    });
    test('Resolving all services that implement a class is successful', () {
      di.startup((context) {
        context.register<String>(() => 'Service 1', name: 'srv1');
        context.register<String>(() => 'Service 2', name: 'srv2');
        context.register<String>(() => 'Service 3', name: 'srv3');
      });

      var services = di.resolveAll<String>();

      expect(services.length, equals(3));
      expect(services.contains('Service 1'), isTrue);
      expect(services.contains('Service 2'), isTrue);
      expect(services.contains('Service 3'), isTrue);
    });
  });
  //
  // ***** Registering and resolving services for profiles is successful *****
  //
  group('Registering and resolving services for profiles is successful', () {
    test('Resolving an unknown service is failing', () {
      di.startup((context) {}, activeProfiles: ['test'], profileInitializers: {'test': (context) {}});

      expect(() => di.resolve<String>(), throwsException);
    });
    test('Register a non-singleton service and resolving it, is successful', () {
      di.startup((context) {}, activeProfiles: [
        'test'
      ], profileInitializers: {
        'test': (context) => context.register<String>(() => 'Hello world!', asSingleton: false)
      });

      var service = di.resolve<String>();

      expect(service, equals('Hello world!'));
    });
    test('Resolving all services that implement a class is successful', () {
      di.startup((context) => context.register<String>(() => 'Service 1', name: 'srv1'), activeProfiles: [
        'test1',
        'test2'
      ], profileInitializers: {
        'test1': (context) => context.register<String>(() => 'Service 2', name: 'srv2'),
        'test2': (context) => context.register<String>(() => 'Service 3', name: 'srv3')
      });

      var services = di.resolveAll<String>();

      expect(services.length, equals(3));
      expect(services.contains('Service 1'), isTrue);
      expect(services.contains('Service 2'), isTrue);
      expect(services.contains('Service 3'), isTrue);
    });
    test('Resolving a service from active profile and global profile with the same name is failing', () {
      di.startup((context) => context.register<String>(() => 'Service 1', name: 'srv'),
          activeProfiles: ['test1'],
          profileInitializers: {'test1': (context) => context.register<String>(() => 'Service 2', name: 'srv')});

      expect(() => di.resolve<String>(name: 'srv'), throwsException);
    });
    test('Resolving a service from active profile with the same name is succeeding', () {
      di.startup((context) {}, activeProfiles: [
        'test1'
      ], profileInitializers: {
        'test1': (context) => context.register<String>(() => 'Service Test 1', name: 'srv'),
        'test2': (context) => context.register<String>(() => 'Service Test 2', name: 'srv')
      });

      expect(di.resolve<String>(name: 'srv'), equals('Service Test 1'));
    });
  });
}
