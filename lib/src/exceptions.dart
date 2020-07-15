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

class InjectionContextNotInitialized extends StateError implements Exception {
  InjectionContextNotInitialized()
      : super('The InjectionContext is not initialized');
}

class InjectionContextAlreadyInitialized extends StateError
    implements Exception {
  InjectionContextAlreadyInitialized()
      : super('The InjectionContext is already initialized');
}

class InjectionContextHasAlreadyService extends StateError
    implements Exception {
  InjectionContextHasAlreadyService(String service, String name)
      : super('The InjectionContext has no registered service $service:$name');
}

class InjectionContextHasNoService extends StateError implements Exception {
  InjectionContextHasNoService(String service, String name)
      : super('The InjectionContext has no registered service $service:$name');
}
