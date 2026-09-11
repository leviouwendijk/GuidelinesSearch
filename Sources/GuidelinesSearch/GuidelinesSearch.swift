import Fuzzy
import Guidelines
import Matching
import Ranking

public struct GuidelineSearchIndex: Sendable {
    public enum Target:
        Sendable,
        Hashable
    {
        case chapterOverview
        case guideline(Int)
    }

    public struct Entry: Sendable {
        public let id: String
        public let chapter: GuidelineChapter
        public let target: Target
        public let title: String
        public let summary: String?

        let candidate: BasicMatchCandidate<String>

        public var reference: String {
            guideline?.reference
                ?? chapter.reference
        }

        public var guideline: Guideline? {
            switch target {
            case .chapterOverview:
                nil

            case .guideline(let index):
                chapter.guidelines[index]
            }
        }
    }

    private let entries: [Entry]
    private let entriesByID: [String: Entry]
    private let fuzzyIndex:
        FuzzyIndex<
            BasicMatchCandidate<String>
        >

    public init(
        chapters: [GuidelineChapter] =
            GuidelineManual.chapters
    ) {
        let entries = chapters.flatMap {
            chapter -> [Entry] in

            var entries: [Entry] = []

            if !GuidelineStructuredContentProjection.isEmpty(
                chapter.introduction
            ) {
                let body = GuidelineStructuredContentProjection.text(
                    chapter.introduction
                )

                let id =
                    "chapter:"
                    + chapter.reference

                entries.append(
                    Entry(
                        id: id,
                        chapter: chapter,
                        target: .chapterOverview,
                        title: chapter.title,
                        summary: "Chapter overview",
                        candidate:
                            BasicMatchCandidate(
                                matchID: id,
                                primaryField:
                                    MatchField(
                                        name: "title",
                                        text: chapter.title,
                                        role: .primary,
                                        weight: 8
                                    ),
                                secondaryFields: [
                                    MatchField(
                                        name: "reference",
                                        text: chapter.reference,
                                        role: .alias,
                                        weight: 7
                                    ),
                                    MatchField(
                                        name: "area",
                                        text: chapter.area.rawValue,
                                        role: .tag,
                                        weight: 2
                                    ),
                                    MatchField(
                                        name: "content",
                                        text: body,
                                        role: .body,
                                        weight: 1
                                    ),
                                ]
                            )
                    )
                )
            }

            entries.append(
                contentsOf:
                    chapter.guidelines
                        .enumerated()
                        .map {
                            index,
                            guideline in

                            let explanation =
                                GuidelineStructuredContentProjection.text(
                                    guideline.explanation
                                )

                            let corpus = [
                                guideline.title,
                                guideline.reference,
                                chapter.title,
                                chapter.reference,
                                chapter.area.rawValue,
                                guideline.summary,
                                explanation,
                            ]
                            .joined(
                                separator: "\n"
                            )

                            let id =
                                "guideline:"
                                + guideline.reference

                            return Entry(
                                id: id,
                                chapter: chapter,
                                target:
                                    .guideline(
                                        index
                                    ),
                                title: guideline.title,
                                summary: guideline.summary,
                                candidate:
                                    BasicMatchCandidate(
                                        matchID: id,
                                        primaryField:
                                            MatchField(
                                                name: "title",
                                                text: guideline.title,
                                                role: .primary,
                                                weight: 8
                                            ),
                                        secondaryFields: [
                                            MatchField(
                                                name: "reference",
                                                text: guideline.reference,
                                                role: .alias,
                                                weight: 7
                                            ),
                                            MatchField(
                                                name: "chapter",
                                                text: chapter.title,
                                                role: .secondary,
                                                weight: 5
                                            ),
                                            MatchField(
                                                name: "summary",
                                                text: guideline.summary,
                                                role: .subtitle,
                                                weight: 4
                                            ),
                                            MatchField(
                                                name: "area",
                                                text: chapter.area.rawValue,
                                                role: .tag,
                                                weight: 2
                                            ),
                                            MatchField(
                                                name: "content",
                                                text: corpus,
                                                role: .body,
                                                weight: 1
                                            ),
                                        ]
                                    )
                            )
                        }
            )

            return entries
        }

        self.entries =
            entries

        self.entriesByID =
            Dictionary(
                uniqueKeysWithValues:
                    entries.map {
                        (
                            $0.id,
                            $0
                        )
                    }
            )

        self.fuzzyIndex =
            FuzzyIndex(
                candidates:
                    entries.map(
                        \.candidate
                    )
            )
    }

    public func search(
        _ rawQuery: String,
        limit: Int = 40
    ) -> [Entry] {
        guard limit > 0 else {
            return []
        }

        return fuzzyIndex
            .rank(
                rawQuery,
                selection:
                    RankingSelectionOptions(
                        limit: min(
                            limit,
                            entries.count
                        )
                    )
            )
            .compactMap {
                entriesByID[
                    $0.value.candidateID
                ]
            }
    }

    public func searchGuidelines(
        _ rawQuery: String,
        limit: Int = 40
    ) -> [Entry] {
        guard limit > 0 else {
            return []
        }

        return Array(
            search(
                rawQuery,
                limit: entries.count
            )
            .filter {
                $0.guideline != nil
            }
            .prefix(limit)
        )
    }
}
