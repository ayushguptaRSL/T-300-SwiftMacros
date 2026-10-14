import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SwiftMacroAssignmentMacros)
import SwiftMacroAssignmentMacros

let testMacros: [String: Macro.Type] = [
    "GenerateCodingKeys": GenerateCodingKeysMacroImpl.self,
]
#endif

final class SwiftMacroAssignmentTests: XCTestCase {
    func testStructArticle() throws {
        #if canImport(SwiftMacroAssignmentMacros)
        assertMacroExpansion(
            """
            @GenerateCodingKeys
            struct Article: Codable {
                let articleId: Int
                let articleTitle: String
                let authorName: String
                let publishedDate: String
            }
            """,
            expandedSource: """
            struct Article: Codable {
                let articleId: Int
                let articleTitle: String
                let authorName: String
                let publishedDate: String

                enum CodingKeys: String, CodingKey {
                    case articleId = "article_id"
                    case articleTitle = "article_title"
                    case authorName = "author_name"
                    case publishedDate = "published_date"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testStructComment() throws {
        #if canImport(SwiftMacroAssignmentMacros)
        assertMacroExpansion(
            """
            @GenerateCodingKeys
            struct Comment: Codable {
                let commentId: Int
                let articleId: Int
                let commenterName: String
                let createdAt: String
            }
            """,
            expandedSource: """
            struct Comment: Codable {
                let commentId: Int
                let articleId: Int
                let commenterName: String
                let createdAt: String
            
                enum CodingKeys: String, CodingKey {
                    case commentId = "comment_id"
                    case articleId = "article_id"
                    case commenterName = "commenter_name"
                    case createdAt = "created_at"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorOnEnum() throws {
        #if canImport(SwiftMacroAssignmentMacros)
        assertMacroExpansion(
            """
            @GenerateCodingKeys
            enum Ayush {
                case ayush1
            }
            """,
            expandedSource: """
            enum Ayush {
                case ayush1
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "Only support the struct", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
