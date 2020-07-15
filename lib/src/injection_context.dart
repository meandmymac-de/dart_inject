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

import 'exceptions.dart';

/// This function type defines the signature for functions that initialize a
/// service instances.
typedef ServiceInitializer<T> = T Function();

/// This the function type definition for the initialization of the available
/// services. The function is called with the [context].
typedef InjectionInitializer = void Function(InjectionContext context);

class _ServiceConfiguration<T> {
  String name;
  ServiceInitializer<T> serviceInitializer;
  bool singleton;
  T serviceInstance;

  _ServiceConfiguration({this.name, this.serviceInitializer, this.singleton});
}

/// The [InjectionContext] is the global registry for all services. It is a
/// singleton, since the context must be the same instance in the entire
/// application.
class InjectionContext {
  /// The singleton instance of the [InjectionContext].
  static final InjectionContext _singleton = InjectionContext._global();

  /// This flag determines whether the [startup] method has been called or not.
  /// If the [startup] method has not been calledm the [InjectionContext] is not
  /// functional and each call to any method results in an error.
  bool _initialized = false;

  Map<String, _ServiceConfiguration> _services = {};

  /// Internal constructor for the singleton.
  InjectionContext._global() {}

  /// This factory always returns the singleton instance of the
  /// [InjectionContext].
  factory InjectionContext() {
    return _singleton;
  }

  /// This method must be called at the very beginning of the application.
  /// It calls the [InjectionInitializer] to initialize itself.
  void startup(InjectionInitializer initializer) {
    if (_initialized) {
      throw InjectionContextAlreadyInitialized();
    }

    _initialized = true;

    initializer(this);
  }

  void register<T>(ServiceInitializer<T> initializer,
      {String name, bool asSingleton = true}) {
    if (!_initialized) {
      throw InjectionContextNotInitialized();
    }

    _services[_key(name)] = _ServiceConfiguration<T>(
        name: name, serviceInitializer: initializer, singleton: asSingleton);
  }

  T resolve<T>({String name}) {
    if (!_initialized) {
      throw InjectionContextNotInitialized();
    }

    var configuration = _services[_key<T>(name)];

    if (configuration.singleton) {
      configuration.serviceInstance ??= configuration.serviceInitializer();

      return configuration.serviceInstance;
    }

    return configuration.serviceInitializer();
  }

  String _key<T>(String name) {
    return T.runtimeType.toString() + ":" + (name ?? T.runtimeType.toString());
  }
}

void register<T>(ServiceInitializer<T> initializer,
        {String name, bool asSingleton = true}) =>
    InjectionContext()
        .register(initializer, name: name, asSingleton: asSingleton);

T resolve<T>({String name}) => InjectionContext().resolve(name: name);
