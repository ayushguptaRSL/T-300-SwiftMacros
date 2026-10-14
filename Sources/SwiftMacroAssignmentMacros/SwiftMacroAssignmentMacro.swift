import SwiftCompilerPlugin
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum GenerateCodingKeysMacroErrors: Error, CustomStringConvertible {
    case supportNotAvailable
    
    var description: String {
        switch self {
        case .supportNotAvailable: "Only support the struct"
        }
    }
}

public struct GenerateCodingKeysMacroImpl: MemberMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 conformingTo protocols: [TypeSyntax],
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let structDec = declaration.as(StructDeclSyntax.self) else { throw GenerateCodingKeysMacroErrors.supportNotAvailable }
        
        let propertiesDec = structDec.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let elements = propertiesDec.flatMap { $0.bindings }
        
        let codingKeyEnums = try EnumDeclSyntax(
            name: "CodingKeys",
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "String"))
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "CodingKey"))
            }) {
                for element in elements {
                    let identifier = element.pattern.as(IdentifierPatternSyntax.self)?.identifier
                    try EnumCaseDeclSyntax("case \(identifier) = \(literal: toSnakeCase(identifier?.text ?? ""))")
                }
        }
        
        return [DeclSyntax(codingKeyEnums)]
    }
    
    private static func toSnakeCase(_ string: String) -> String {
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: string.count)

        let snakeCaseString = regex?.stringByReplacingMatches(
            in: string,
            options: [],
            range: range,
            withTemplate: "$1_$2"
        )
        
        return snakeCaseString?.lowercased() ?? string
    }
}

@main
struct GenerateCodingKeyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GenerateCodingKeysMacroImpl.self,
    ]
}
