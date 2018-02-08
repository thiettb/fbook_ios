//
//  API.swift
//
//  Created by nguyen.van.hung on 6/29/17.
//  Copyright © 2017 nguyen.van.hung. All rights reserved.
//

import Foundation
import ReactiveSwift
import Moya

enum API {

    case login(String, String)
    case home
    case homeFilter
    case getUserProfile
    case getOtherUserProfile(Int)
    case getListOffice
    case getBookDetail(Int)
    case searchBook(Int?, Int, SearchBookParams)
    case searchGoogleBook(Int, String)
    case getBookInSection(Int?, Int, SectionBook)
    case getBookFilterSortInSection(Int?, Int, FilterSortBookParams)
    case getListNotifications
    case bookingBook(BookingBookParams)
    case getFollowInfoOfUser(Int)
    case getListWaitingApprovedBook(Int)
    case getBookApproveDetail(Int)
    case approveBook(Int, ApproveBookParams)
    case getCategories
    case getBooksInCategory(Int, Int)
    case followUser(Int)
    case reviewBook(Int, Review)
    case shareBook(String, String?, String, Date?, Int?, Int?, [Medias])
}

extension API: TargetType {

    static var debugMode = true
    static let baseURLStringProd = "http://api-book.framgia.vn/api/v0"
    static let baseURLStringDebug = "http://172.16.0.6:4000/api/v0"

    public var baseURL: URL {
        if API.debugMode {
            return URL(string: API.baseURLStringDebug)!
        }
        return URL(string: API.baseURLStringProd)!
    }

    public var path: String {
        switch self {
        case .login:
            return "/login"
        case .home:
            var path = "/home"
            if let id = Office.currentId {
                path.append("/?office_id=\(id)")
            }
            return path
        case .homeFilter:
            return "/home/filters"
        case .getUserProfile:
            return "/user-profile"
        case .getOtherUserProfile(let userId):
            return "/users/\(userId)"
        case .getListOffice:
            return "/offices"
        case .getBookDetail(let bookId):
            return "/books/\(bookId)"
        case .searchBook(let officeId, let page, _):
            var path = "/search?page=\(page)"
            if let id = officeId {
                path.append("&office_id=\(id)")
            }
            return path
        case .searchGoogleBook:
            return "/search-books"
        case .getBookInSection:
            return "/books"
        case .getBookFilterSortInSection(let officeId, let page, let param):
            var path = "/books/filters?page=\(page)&condition=\(param.sort.rawValue)"
            if let id = officeId {
                path.append("&office_id=\(id)")
            }
            print("PATH \(path)")
            return path
        case .getListNotifications:
            return "/notifications"
        case .bookingBook:
            return "/books/booking"
        case .getFollowInfoOfUser(let userId):
            return "/users/follow/info/\(userId)"
        case .getListWaitingApprovedBook(let page):
            return "/user/books/waiting_approve?page=\(page)"
        case .getBookApproveDetail(let bookId):
            return "/user/\(bookId)/approve/detail"
        case .approveBook(let bookId, _):
            return "/books/approve/\(bookId)"
        case .getCategories:
            return "/categories"
        case .getBooksInCategory(let categoryId, _):
            return "/books/category/\(categoryId)"
        case .followUser:
            return "/users/follow"
        case .reviewBook(let bookId, _):
            return "/books/review/\(bookId)"
        case .shareBook:
            return "/books"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .login, .homeFilter, .searchBook, .bookingBook, .approveBook, .followUser, .reviewBook,
                 .getBookFilterSortInSection, .shareBook:
            return .post
        default:
            return .get
        }
    }

    public var parameters: [String : Any]? {
        switch self {
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .searchBook(_, _, let params):
            return params.toRequestJSON()
        case .searchGoogleBook(let maxResults, let searchText):
            return ["maxResults": maxResults, "q": searchText]
        case .getBookInSection(let officeId, let page, let sectionBook):
            var parameters: [String : Any] = ["page": page, "field": sectionBook.key]
            if let officeId = officeId {
                parameters["office_id"] = officeId
            }
            return parameters
        case .getBookFilterSortInSection(_, _, let params):
            print("PARAM \(params.toRequestJSON())")
            return params.toRequestJSON()
        case .bookingBook(let params):
            return params.toRequestJSON()
        case .approveBook(_, let params):
            return params.toRequestJSON()
        case .getBooksInCategory(_, let page):
            var parameters: [String : Any] = ["page": page]
            if let officeId = Office.currentId {
                parameters["office_id"] = officeId
            }
            return parameters
        case .followUser(let userId):
            return [kItem: ["user_id": userId]]
        case .reviewBook(_, let review):
            let params: [String: Any] = [
                "content": review.content,
                "star": review.star
            ]
            return [kItem: params]
        case .shareBook(let title, let description, let author, let publish_date, let category_id, let office_id, let medias):
            guard let description = description, let publish_date = publish_date, let category_id = category_id, let office_id = office_id else {
                return [:]
            }
            let params: [String: Any] = [
                "title": title,
                "description": description,
                "author": author,
                "publish_date": publish_date,
                "category_id": category_id,
                "office_id": office_id,
                "medias": medias
            ]
            return params
        default:
            return nil
        }
    }

    public var parameterEncoding: ParameterEncoding {
        switch method {
        case .post: return JSONEncoding.default
        default: return URLEncoding.default
        }
    }

    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }

    public var task: Task {
        return Task.request
    }

    public var validate: Bool {
        return false
    }
}
