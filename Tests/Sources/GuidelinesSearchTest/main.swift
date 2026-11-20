import Guidelines
import GuidelinesSearch

enum GuidelinesSearchTestFailure: Error {
    case noGuidelines
    case exactReferenceDidNotRankFirst
    case canonicalGuidelineWasNotPreserved
    case zeroLimitWasNotEmpty
}

@main
enum GuidelinesSearchTestMain {
    static func main() throws {
        guard let guideline = Guideline.all.first else {
            throw GuidelinesSearchTestFailure.noGuidelines
        }

        let index = GuidelineSearchIndex()

        let matches = index.searchGuidelines(
            guideline.reference,
            limit: 5
        )

        guard matches.first?.reference == guideline.reference else {
            throw GuidelinesSearchTestFailure
                .exactReferenceDidNotRankFirst
        }

        guard matches.first?.guideline == guideline else {
            throw GuidelinesSearchTestFailure
                .canonicalGuidelineWasNotPreserved
        }

        guard index.searchGuidelines(
            guideline.reference,
            limit: 0
        ).isEmpty else {
            throw GuidelinesSearchTestFailure
                .zeroLimitWasNotEmpty
        }

        print(
            "GuidelinesSearch: exact-reference ranking and canonical lookup passed."
        )
    }
}
