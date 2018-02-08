//
//  BookProvider.swift
//  FBook
//
//  Created by Ban Nguyen Ngoc on 9/7/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ReactiveSwift
import ObjectMapper

final class BookProvider: BaseProvider {

    typealias BookDetailSignal = SignalProducer<Book, ErrorResponse>
    typealias BookListSignal = SignalProducer<ListItems<Book>, ErrorResponse>
    typealias GoogleBookListSignal = SignalProducer<[GoogleBook], ErrorResponse>

    static func getBookDetail(bookId: Int) -> BookDetailSignal {
        return requestJSON(api: .getBookDetail(bookId)).flatMap(.merge, mapBook)
    }

    static func searchBook(officeId: Int?, page: Int, params: SearchBookParams) -> BookListSignal {
        return requestJSON(api: .searchBook(officeId, page, params)).flatMap(.merge, mapBookList)
    }

    static func searchGoogleBook(maxResults: Int, searchText: String) -> GoogleBookListSignal {
        return requestJSON(api: .searchGoogleBook(maxResults, searchText)).flatMap(.merge, mapGoogleBookList)
    }

    static func getBooks(inSection section: SectionBook, page: Int, officeId: Int?) -> BookListSignal {
        return requestJSON(api: .getBookInSection(officeId, page, section)).flatMap(.merge, mapBookList)
    }

    static func getBooksFilterSort( params: FilterSortBookParams, page: Int, officeId: Int?) -> BookListSignal {
        return requestJSON(api: .getBookFilterSortInSection(officeId, page, params))
            .flatMap(.merge, mapBookList)
    }

    static func bookingBook(params: BookingBookParams) -> BooleanSignal {
        return requestJSON(api: .bookingBook(params)).flatMap(.merge, mapBoolean)
    }

    static func getListWaitingApprovedBook(page: Int) -> BookListSignal {
        return requestJSON(api: .getListWaitingApprovedBook(page)).flatMap(.merge, mapBookList)
    }

    static func getBookApprovedDetail(bookId: Int) -> BookDetailSignal {
        return requestJSON(api: .getBookApproveDetail(bookId)).flatMap(.merge, mapBook)
    }

    static func approveBook(bookId: Int, params: ApproveBookParams) -> BooleanSignal {
        return requestJSON(api: .approveBook(bookId, params)).flatMap(.merge, mapBoolean)
    }

    static func reviewBook(bookId: Int, review: Review) -> BooleanSignal {
        return requestJSON(api: .reviewBook(bookId, review)).flatMap(.merge, mapBoolean)
    }
    
    static func shareBook(title: String, description: String?, author: String, publishDate: Date?, categoryId: Int?, officeId: Int?, medias: [Medias]) -> BooleanSignal {
        return requestJSON(api: .shareBook(title, description, author, publishDate, categoryId, officeId, medias)).flatMap(.merge, mapBoolean)
    }

    fileprivate static let mapBookList = { (object: ObjectResponse?) -> BookListSignal in
        if let value = object?.value as? [String: Any], let items = value[kItems] as? [String: Any],
            let listBooks = ListItems<Book>(JSON: items) {
            return BookListSignal(value: listBooks)
        }
        return BookListSignal(error: .errorJsonFormat)
    }

    fileprivate static let mapBook = { (object: ObjectResponse?) -> BookDetailSignal in
        if let value = object?.value as? [String: Any], let item = value[kItem] as? [String: Any],
            let book = Book(JSON: item) {
            return BookDetailSignal(value: book)
        }
        return BookDetailSignal(error: .errorJsonFormat)
    }

    fileprivate static let mapGoogleBookList = { (object: ObjectResponse?) -> GoogleBookListSignal in
        if let value = object?.value as? [String: Any], let items = value[kItems] as? [[String: Any]] {
            let googleBooks = items.flatMap { GoogleBook(JSON: $0) }
            return GoogleBookListSignal(value: googleBooks)
        }
        return GoogleBookListSignal(error: .errorJsonFormat)
    }
}
