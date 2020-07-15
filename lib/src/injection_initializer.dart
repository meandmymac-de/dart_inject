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

import 'injection_context.dart';

/// The [InjectionInitializer] must be implemented by an application and an
/// instance must be passed to the [startupDependencyInjection] function.
abstract class InjectionInitializer {
  /// This getter can be overriden and should return all active profiles.
  /// If no profile is returned, only those services are made available that
  /// are not assigned to a profile. All others won't be available.
  /// An empty profile name is not allowed and results in an error. Also the
  /// profile name `GLOBAL` in any character capitlization is not allowed, since
  /// it is the profile name for all services that are not assigned to a
  /// specific profile.
  ///
  /// The default implementation returns an empty list, hence only the `GLOBAL`
  /// profile is active.
  List<String> get activeProfiles => [];

  /// This method must be overriden. The method is repsonsible for registering
  /// all services that shall be injectable.
  ///
  /// The [context] is the global context which shall be used to register the
  /// services.
  ///
  /// If profiles are enabled, this method is called for all profiles
  /// separately.
  void registerServices(InjectionContext context, {String profile});
}
