import DSL

public enum GuidelineStructuredContentProjection {
    public static func isEmpty(
        _ content: StructuredContent
    ) -> Bool {
        text(content).allSatisfy {
            $0.isWhitespace
        }
    }

    public static func text(
        _ content: StructuredContent
    ) -> String {
        switch content {
        case .collection(let content):
            return joined(
                content.map(text)
            )

        case .paragraph(let content):
            return text(content)

        case .code(
            _,
            let source
        ):
            return source

        case .quote(let content):
            return text(content)

        case .list(
            _,
            let items
        ):
            return joined(
                items.map(text)
            )

        case .group(
            _,
            let title,
            let content
        ):
            return joined([
                title.map(text) ?? "",
                text(content),
            ])

        case .table(
            let header,
            let rows
        ):
            return joined(
                ([header] + rows).flatMap {
                    $0.map(text)
                }
            )
        }
    }

    private static func text(
        _ content: [StructuredContent.Inline]
    ) -> String {
        content
            .map(text)
            .joined()
    }

    private static func text(
        _ content: StructuredContent.Inline
    ) -> String {
        switch content {
        case .text(let content),
             .code(let content):
            return content

        case .emphasis(let content),
             .strong(let content):
            return text(content)
        }
    }

    private static func joined(
        _ content: [String]
    ) -> String {
        content
            .filter {
                !$0.isEmpty
            }
            .joined(
                separator: "\n"
            )
    }
}
