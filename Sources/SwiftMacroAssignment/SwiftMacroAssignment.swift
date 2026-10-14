// Generate automatic codingKeys for the struct
@attached(member, names: named(CodingKeys))
public macro GenerateCodingKeys() = #externalMacro(module: "SwiftMacroAssignmentMacros", type: "GenerateCodingKeysMacroImpl")

