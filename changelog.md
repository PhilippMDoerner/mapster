# Changelog

-   [!]—backward incompatible change
-   [+]—new feature
-   [f]—bugfix
-   [r]—refactoring
-   [t]—test suite improvement
-   [d]—docs improvement

## 1.0.0 (August 19, 2023)
- [+] Add compile-time validation of assignments
- [r] Unify more operations between object variant and normal mapping into utils.nim
- [!] rename private packages to "map.nim" and "mapVariant".nim
- [t] Moved to testament to be able to test compile-time validation

## 0.2.0 (August 13, 2023)
- [+] Add mapping of object variants
- [r] Improve error messages for wrong useage

## 0.1.3 (August 11, 2023)
- [f] Fix seq types in parameters bricking map proc body generation

## 0.1.2 (August 11, 2023)
- [f] Fix mapster not working with identifiers that are the same under nim rules (isBla and is_bla) but not string equal

## 0.1.1 (August 11, 2023)
- [r] Clean up work, removed early testing code that wasn't part of the test-suite

## 0.1.0 (August 11, 2023)
-   🎉 initial release.