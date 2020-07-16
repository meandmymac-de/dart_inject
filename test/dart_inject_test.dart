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

import 'package:dart_inject/dart_inject.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() => InjectionContext().shutDown());
  //
  // ***** Instantiating the injection context *****
  //
  group('Instantiating the injection context', () {
    test('The injection context is available', () {
      expect(InjectionContext(), isNotNull);
    });

    test('The injection context is always the same', () {
      expect(InjectionContext(), equals(InjectionContext()));
    });
  });
  //
  // ***** Check initialization logic *****
  //
  group('Check initialization logic', () {
    test('Registering a service without startup is not only possible', () {
      expect(() => InjectionContext().register<String>(() => ''), throwsException);
    });

    test('Starting the injection context more than once is not possible', () {
      expect(() {
        InjectionContext().startup((context) {});
        InjectionContext().startup((context) {});
      }, throwsException);
    });
    test('Resolving without an initialized injection context is failing', () {
      expect(() => resolve<String>(), throwsException);
    });
  });
  //
  // ***** Registering an resolving services is successful *****
  //
  group('Registering and resolving services is successful', () {
    test('Resolving an unknown service is failing', () {
      InjectionContext().startup((context) {});

      expect(() => resolve<String>(), throwsException);
    });
    test('Register a non-singleton service and resolving it, is successful', () {
      InjectionContext().startup((context) {
        register<String>(() => 'Hello world!', asSingleton: false);
      });

      var service = resolve<String>();

      expect(service, equals('Hello world!'));
    });
    test('Register a non-singleton service creates new instances on resolution', () {
      var instNum = 0;
      InjectionContext().startup((context) {
        register<String>(() {
          instNum++;
          return "I'm instance $instNum";
        }, asSingleton: false);
      });

      var service1 = resolve<String>();
      var service2 = resolve<String>();

      expect(service1, equals("I'm instance 1"));
      expect(service2, equals("I'm instance 2"));
      expect(identical(service1, service2), isFalse);
    });
    test('Register a singleton service returns the same instances on resolution', () {
      var instNum = 0;
      InjectionContext().startup((context) {
        register<String>(() {
          instNum++;
          return "I'm instance $instNum";
        }, asSingleton: true);
      });

      var service1 = resolve<String>();
      var service2 = resolve<String>();

      expect(service1, equals("I'm instance 1"));
      expect(service2, equals("I'm instance 1"));
      expect(identical(service1, service2), isTrue);
    });
    test('Registering services with same type and different names and resolving them is successful', () {
      InjectionContext().startup((context) {
        register<String>(() => "I'm a Cat", name: 'Cat', asSingleton: false);
        register<String>(() => "I'm a Dog", name: 'Dog', asSingleton: false);
      });

      var cat = resolve<String>(name: 'Cat');
      var dog = resolve<String>(name: 'Dog');

      expect(cat, equals("I'm a Cat"));
      expect(dog, equals("I'm a Dog"));
    });
    test('Registering two services with same type and names is not successful', () {
      expect(
          () => InjectionContext().startup((context) {
                register<String>(() => "I'm a Cat", name: 'Pet', asSingleton: false);
                register<String>(() => "I'm a Dog", name: 'Pet', asSingleton: false);
              }),
          throwsException);
    });
  });
}
