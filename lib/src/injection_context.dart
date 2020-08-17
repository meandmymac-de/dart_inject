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

import 'dart:collection';

import 'exceptions.dart';

String _stringOfType<T>() => T.toString();

/// This function type defines the signature for functions that initialize a
/// service instances.
typedef ServiceInitializer<T> = T Function();

/// This the function type definition for the initialization of the available
/// services.
typedef InjectionInitializer = void Function(Context);

class _ServiceConfiguration<T> {
  String name;
  ServiceInitializer<T> serviceInitializer;
  bool singleton;
  T serviceInstance;

  _ServiceConfiguration({this.name, this.serviceInitializer, this.singleton});
}

/// This singleton class holds all context for the different profiles.
class _ContextCollection {
  /// Name of the global profiles.
  static final String globalProfile = '_____GLOBAL_____';

  /// The singleton instance.
  static final _ContextCollection _singleton = _ContextCollection._global();

  /// Maps with all assignments from profile name to its injection context.
  Map<String, _InjectionContext> profiles = {
    _ContextCollection.globalProfile: _InjectionContext(profile: _ContextCollection.globalProfile)
  };

  /// All active profiles
  List<String> activeProfiles = [];

  /// Internal constructor for the singleton.
  _ContextCollection._global();

  /// Getter for the shared instance.
  static _ContextCollection get shared => _ContextCollection._singleton;

  List<_InjectionContext> get _activeContexts =>
      activeProfiles.map<_InjectionContext>((profile) => _getContext(profile)).toList();

  _InjectionContext get globalContext {
    return _getContext(globalProfile);
  }

  _InjectionContext _getContext(String profile) {
    var context;

    if (profiles.containsKey(profile)) {
      context = profiles[profile];
    } else {
      context = _InjectionContext(profile: profile);
      profiles[profile] = context;
    }

    return context;
  }

  void startupContext(String profile, InjectionInitializer initializer) {
    _getContext(profile).startup(initializer);
  }

  void shutdown() {
    profiles.values.forEach((context) => context.shutdown());
    profiles = {};
    activeProfiles = [];
  }
}

/// This abstract class is implemented by the internal injection context
/// and provides the interface for registering services.
abstract class Context {
  /// This method shall be called to register a service with the injection
  /// context. It must only be called, after the [startup] has been called.
  ///
  /// The [initializer] is called when an instance of the service shall be
  /// created. It must return the instance of the service. By passing a [name],
  /// it is possible to register different services that implement the same
  /// class. If the flag [asSingleton] is true, the [globalInitializer] is only called
  /// once when resolving the service. The created service instance will be
  /// cached. If the flag [asSingleton] is false, the [initializer] is called
  /// every time when resolving the service.
  ///
  /// Throws a [InjectionContextNotInitialized] exception, if the injection
  /// context is not started.
  ///
  /// Throws a [InjectionContextHasAlreadyService] exception, if the service
  /// that shall be registered was already registered before.
  void register<T>(
    ServiceInitializer<T> globalInitializer, {
    String name,
    bool asSingleton = true,
  });
}

/// The [_InjectionContext] is the global registry for all services. It is a
/// singleton, since the context must be the same instance in the entire
/// application.
class _InjectionContext implements Context {
  String profile;

  /// This flag determines whether the [startup] method has been called or not.
  /// If the [startup] method has not been calledm the [_InjectionContext] is not
  /// functional and each call to any method results in an error.
  bool _initialized = false;

  Map<String, _ServiceConfiguration> _services = HashMap<String, _ServiceConfiguration>();

  /// This factory always returns the singleton instance of the
  /// [_InjectionContext].
  _InjectionContext({this.profile});

  /// This method must be called at the very beginning of the application.
  /// It calls the [InjectionInitializer] to initialize itself.
  void startup(InjectionInitializer initializer) {
    if (_initialized) {
      throw InjectionContextAlreadyInitialized();
    }

    _initialized = true;

    initializer(this);
  }

  /// This method can be called to reset the injection context. Every registered
  /// service and all singleton instances will be removed.
  void shutdown() {
    _initialized = false;
    _services = HashMap<String, _ServiceConfiguration>();
  }

  /// This method shall be called to register a service with the injection
  /// context. It must only be called, after the [startup] has been called.
  ///
  /// The [initializer] is called when an instance of the service shall be
  /// created. It must return the instance of the service. By passing a [name],
  /// it is possible to register different services that implement the same
  /// class. If the flag [asSingleton] is true, the [globalInitializer] is only called
  /// once when resolving the service. The created service instance will be
  /// cached. If the flag [asSingleton] is false, the [initializer] is called
  /// every time when resolving the service.
  ///
  /// Throws a [InjectionContextNotInitialized] exception, if the injection
  /// context is not started.
  ///
  /// Throws a [InjectionContextHasAlreadyService] exception, if the service
  /// that shall be registered was already registered before.
  @override
  void register<T>(
    ServiceInitializer<T> globalInitializer, {
    String name,
    bool asSingleton = true,
  }) {
    if (!_initialized) {
      throw InjectionContextNotInitialized();
    }

    if (_services.containsKey(_key<T>(name))) {
      throw InjectionContextHasAlreadyService(_stringOfType<T>(), (name ?? _stringOfType<T>()));
    }

    _services[_key<T>(name)] =
        _ServiceConfiguration<T>(name: name, serviceInitializer: globalInitializer, singleton: asSingleton);
  }

  /// This method resolves a service determined by the type [T] and an optional
  /// [name].
  ///
  /// Throws a [InjectionContextNotInitialized] exception, if the injection
  /// context is not started.
  ///
  /// Throws a [InjectionContextHasNoService] exception, if the service
  /// that shall be resolved was not registered before.
  T resolve<T>({String name}) {
    if (!_initialized) {
      throw InjectionContextNotInitialized();
    }

    if (!_services.containsKey(_key<T>(name))) {
      throw InjectionContextHasNoService(_stringOfType<T>(), (name ?? _stringOfType<T>()));
    }

    return _instanceForConfiguration(_services[_key<T>(name)]);
  }

  /// This method resolves a service determined by the type [T].
  ///
  /// Throws a [InjectionContextNotInitialized] exception, if the injection
  /// context is not started.
  List<T> resolveAll<T>() {
    if (!_initialized) {
      throw InjectionContextNotInitialized();
    }

    return _services.keys
        .toList()
        .where((key) => key.startsWith(_stringOfType<T>() + ':'))
        .map<T>((key) => _instanceForConfiguration<T>(_services[key]))
        .toList();
  }

  dynamic _instanceForConfiguration<T>(_ServiceConfiguration<T> configuration) {
    if (configuration.singleton) {
      configuration.serviceInstance ??= configuration.serviceInitializer();

      return configuration.serviceInstance;
    }

    return configuration.serviceInitializer();
  }

  String _key<T>(String name) {
    var key = '';

    key = key + _stringOfType<T>() + ':' + (name ?? _stringOfType<T>());

    return key;
  }

  bool _hasService<T>({String name}) {
    return _services.containsKey(_key<T>(name));
  }
}

/// This function must be called at the very beginning of the application to initialize
/// the injection context. The [initializer] is the one for the gloabl profile. The
/// [activeProfiles] is a list of all the profile names that are currently activated.
/// When resolving a service, the global profile and the all the activated profiles are
/// used to search a service, where the global propfile has the least priority.
/// The map [profileInitializers] are the initializers for the differemt know profiles.
void startup(InjectionInitializer initializer,
    {List<String> activeProfiles, Map<String, InjectionInitializer> profileInitializers}) {
  _ContextCollection.shared.activeProfiles.addAll(activeProfiles ?? []);
  _ContextCollection.shared.activeProfiles.add(_ContextCollection.globalProfile);

  var globalContext = _ContextCollection.shared.globalContext;
  globalContext.startup(initializer);

  if (profileInitializers != null) {
    profileInitializers.keys.toList().forEach((profile) {
      _ContextCollection.shared.startupContext(profile, profileInitializers[profile]);
    });
  }
}

/// This function can be called to reset the injection context. Every registered
/// service and all singleton instances will be removed.
void shutdown() {
  _ContextCollection.shared.shutdown();
}

/// This function resolves a service determined by the type [T] and an optional
/// [name].
///
/// Throws a [InjectionContextNotInitialized] exception, if the injection
/// context is not started.
///
/// Throws a [InjectionContextHasNoService] exception, if the service
/// that shall be resolved was not registered before.
T resolve<T>({String name}) {
  var services = _ContextCollection.shared._activeContexts
      .where((context) => context._hasService<T>(name: name))
      .map<T>((context) => context.resolve<T>(name: name))
      .toList();

  if (services.length > 1) {
    throw InjectionContextHasMoreThanOneService(services);
  } else if (services.isEmpty) {
    throw InjectionContextHasNoService(_stringOfType<T>(), (name ?? _stringOfType<T>()));
  }

  return services.first;
}

/// This function resolves a service determined by the type [T].
///
/// Throws a [InjectionContextNotInitialized] exception, if the injection
/// context is not started.
List<T> resolveAll<T>() {
  var services = List<T>();

  _ContextCollection.shared.profiles.values.forEach((context) => services.addAll(context.resolveAll<T>()));

  return services;
}
