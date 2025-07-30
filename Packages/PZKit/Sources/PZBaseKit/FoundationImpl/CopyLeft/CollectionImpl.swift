// This implementation is considered as copyleft from public domain.

infix operator ++=: AdditionPrecedence

// MARK: - ArrayBuilder

@resultBuilder
public enum ArrayBuilder<Element> {
    public static func buildEither(first elements: [Element]) -> [Element] {
        elements
    }

    public static func buildEither(second elements: [Element]) -> [Element] {
        elements
    }

    public static func buildOptional(_ elements: [Element]?) -> [Element] {
        elements ?? []
    }

    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }

    public static func buildExpression(_: ()) -> [Element] {
        []
    }

    public static func buildBlock(_ elements: [Element]...) -> [Element] {
        elements.flatMap { $0 }
    }

    public static func buildArray(_ elements: [[Element]]) -> [Element] {
        Array(elements.joined())
    }
}

// MARK: - Syntax Sugars for Array.

extension Array {
    public static func += (lhs: inout Array, rhs: Element) {
        lhs.append(rhs)
    }

    public static func ++= (lhs: inout Array, rhs: any Sequence<Element>) {
        lhs.append(contentsOf: rhs)
    }

    public static func += (lhs: inout Array, rhs: () async -> Element) async {
        let rhsResult = await rhs()
        lhs.append(rhsResult)
    }

    public static func ++= (lhs: inout Array, rhs: () async -> any Sequence<Element>) async {
        let rhsResult = await rhs()
        lhs ++= rhsResult
    }

    public static func ++= (
        lhs: inout Array, @ArrayBuilder<Element> rhs: () -> Self
    ) {
        lhs.append(contentsOf: rhs())
    }

    public mutating func asyncAppend(_ element: () async -> any Sequence<Element>) async {
        await self += element()
    }

    public mutating func asyncAppend(_ element: () async throws -> Element) async throws {
        let elementFetched = try await element()
        append(elementFetched)
    }

    public mutating func asyncAppend(
        contentsOf elements: () async -> any Sequence<Element>
    ) async {
        await self ++= elements
    }

    public mutating func asyncAppend(
        contentsOf elements: () async throws -> any Sequence<Element>
    ) async throws {
        let elementFetched = try await elements()
        self ++= elementFetched
    }

    public mutating func append(
        @ArrayBuilder<Element> contentsBuilder: () -> Self
    ) {
        self ++= contentsBuilder()
    }
}

// MARK: - SetBuilder

@resultBuilder
public enum SetBuilder<Element> {
    public static func buildEither(first elements: Set<Element>) -> Set<Element> where Element: Hashable {
        elements
    }

    public static func buildEither(second elements: Set<Element>) -> Set<Element> where Element: Hashable {
        elements
    }

    public static func buildOptional(_ elements: Set<Element>?) -> Set<Element> where Element: Hashable {
        elements ?? []
    }

    public static func buildExpression(_ expression: Element) -> Set<Element> where Element: Hashable {
        [expression]
    }

    public static func buildExpression(_: ()) -> Set<Element> where Element: Hashable {
        []
    }

    public static func buildBlock(_ elements: Set<Element>...) -> Set<Element> where Element: Hashable {
        Set(elements.flatMap { $0 })
    }

    public static func buildArray(_ elements: Set<Set<Element>>) -> Set<Element> where Element: Hashable {
        Set(elements.joined())
    }
}

// MARK: - Syntax Sugars for Array.

extension Set {
    public static func += (lhs: inout Set, rhs: Element) {
        lhs.insert(rhs)
    }

    public static func ++= (lhs: inout Set, rhs: any Sequence<Element>) {
        rhs.forEach {
            lhs.insert($0)
        }
    }

    public static func += (lhs: inout Set, rhs: () async -> Element) async {
        let rhsResult = await rhs()
        lhs.insert(rhsResult)
    }

    public static func ++= (lhs: inout Set, rhs: () async -> any Sequence<Element>) async {
        let rhsResult = await rhs()
        lhs ++= rhsResult
    }

    public static func ++= (
        lhs: inout Set, @SetBuilder<Element> rhs: () -> Self
    ) {
        rhs().forEach {
            lhs.insert($0)
        }
    }

    public static func ++= (
        lhs: inout Set, @ArrayBuilder<Element> rhs: () -> [Element]
    ) {
        rhs().forEach {
            lhs.insert($0)
        }
    }

    public mutating func asyncInsert(_ element: () async -> Element) async {
        await self += element
    }

    public mutating func asyncInsert(_ element: () async throws -> Element) async throws {
        let elementFetched = try await element()
        insert(elementFetched)
    }

    public mutating func asyncInsert(
        contentsOf elements: () async -> any Sequence<Element>
    ) async {
        await self ++= elements
    }

    public mutating func asyncInsert(
        contentsOf elements: () async throws -> any Sequence<Element>
    ) async throws {
        let elementFetched = try await elements()
        self ++= elementFetched
    }

    public mutating func insert(
        @SetBuilder<Element> contentSetBuilder: () -> Self
    ) {
        self ++= contentSetBuilder()
    }

    public mutating func insert(
        @ArrayBuilder<Element> contentArrayBuilder: () -> [Element]
    ) {
        self ++= contentArrayBuilder()
    }
}
