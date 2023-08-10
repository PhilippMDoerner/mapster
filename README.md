# Mapster
#### _Because life's too short to map A to B_
**Mapster** is a simple package to help generate procedures/functions for you to map an instance of type A to type B.

Very often A and B share a lot of fields and there is only a small set of exceptions where actual logic is required.

Mapster helps by adding all assignments from instance A to B to the proc for you where the field names and types are identical, allowing you to focus on the few fields that require logic.

## Supports
- Single Parameter mapping procs(A --> B)
- Multi Parameter mapping procs ((A1, A2, ...) --> B)
- Any amount of custom assignments or logic within the mapping proc
- Object types
- Ref Types
- Named Tuples

## Examples
### Mapping without custom Logic
TBD
### Mapping with custom Logic
TBD
### Mapping with ignored fields
TBD
