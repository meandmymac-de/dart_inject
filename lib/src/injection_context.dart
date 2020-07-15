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

import 'injection_initializer.dart';

typedef ServiceInitializer<T> = T Function();

/// The [InjectionContext] is the global registry for all services. It is a
/// singleton, since the context must be the same instance in the entire
/// application.
class InjectionContext {
  static const String globalProfile = 'GLOBAL';

  /// The singleton instance of the [InjectionContext].
  static final InjectionContext _singleton = InjectionContext._global();

  /// Internal constructor for the singleton.
  InjectionContext._global() {
    _profile = globalProfile;
    _profileContexts[_profile] = this;
  }

  /// Internal constructor for profile specific [InjectionContext]s.
  InjectionContext._profile(String profile) {
    _profile = profile;
    _profileContexts[_profile] = this;
  }

  /// The profile for which this [InjectionContext] is responsible.
  String _profile;

  final Map<String, InjectionContext> _profileContexts = {};

  /// This flag determines whether the [startup] method has been called or not.
  /// If the [startup] method has not been calledm the [InjectionContext] is not
  /// functional and each call to any method results in an error.
  bool _initialized = false;

  /// This factory always returns the singleton instance of the
  /// [InjectionContext].
  factory InjectionContext() {
    return _singleton;
  }

  /// This method must be called at the very beginning of the application.
  /// It calls the methods of the [InjectionInitializer] to initialize itself.
  ///
  /// If the [InjectionInitializer] returns any active profile, the method
  /// [InjectionInitializer.registerServices] is called for each and every
  /// profile, such that services can be registered.
  void startup(InjectionInitializer initializer) {
    _initialized = true;
  }

  void register<T>(ServiceInitializer<T> initializer,
      {String profile = globalProfile, String name, bool asSingleton = true}) {}

  T resolve<T>({String profile = globalProfile, String name}) {
    return null;
  }
}

void register<T>(ServiceInitializer<T> initializer,
        {String profile = InjectionContext.globalProfile,
        String name,
        bool asSingleton = true}) =>
    InjectionContext().register(initializer,
        profile: profile, name: name, asSingleton: asSingleton);

T resolve<T>({String profile = InjectionContext.globalProfile, String name}) =>
    InjectionContext().resolve(profile: profile, name: name);
