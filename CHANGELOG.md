## 1.0.0
- It is now possible to define profiles. If a service is assigned to a profile, it only gets resolved, if the profile to which it is assigned, is active.
- The function `shutDown` has been renamed to `shutdown`.

## 0.2.4
- Some code cleanup.

## 0.2.3
- Some code optimiziation.

## 0.2.2
- dart_inject is now compatible with flutter.

## 0.2.1
- Removed the injection context from all public functions and function type definitions.

## 0.2.0

- Bug fixes.
- The class InjectionContext is now private and the functions are the only API starting as of this version.
  - There are new function `startup` and `shutDown` to start and reset the injection context.
- Added the function `resolveAll` to retrieve all services that implement the given class

## 0.1.0

- Initial version
