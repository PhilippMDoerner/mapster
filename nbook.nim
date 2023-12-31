import nimibook

var book = initBookWithToc:
  entry("Welcome To Mapster!", "index.nim")
  entry("Mapping Individual Parameters", "basicUsage.nim")
  entry("Mapping Multiple Parameters", "multipleParameters.nim")
  entry("Mapping To Object Variants", "objectVariants.nim")
  entry("Mapping In Place", "inplaceMapExamples.nim")
  entry("Mapping With Validation", "mapValidation.nim")
  entry("Changelog", "changelog.nim")

nimibookCli(book)
