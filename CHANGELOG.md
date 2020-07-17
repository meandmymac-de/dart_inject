## 0.1.0

- Initial version

## 0.2.0

- Bug fixes.
- The class InjectionContext is now private and the functions are the only API starting as of this version.
  - There are new function `startup` and `shutDown` to start and reset the injection context.
- Added the function `resolveAll` to retrieve all services that implement the given class