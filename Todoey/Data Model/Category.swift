//
//  Category.swift
//  Todoey
//
//  Created by Virak Ngauv on 2/26/18.
//  Copyright © 2018 Virak Ngauv. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
