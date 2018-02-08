//
//  ShareBookParams.swift
//  FBook
//
//  Created by ThietTB on 2/9/18.
//  Copyright © 2018 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

struct Medias {
    var file: String?
    var type: Int?
}

struct ShareBookParams {
    
    var title = ""
    var description: String?
    var author: String?
    var publishDate: Date?
    var categoryID: Category?
    var officeID: Office?
    var medias: [Medias]
}
