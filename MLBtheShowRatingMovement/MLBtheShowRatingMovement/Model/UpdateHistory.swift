//
//  UpdateHistory.swift
//  MLBtheShowRatingMovement
//
//  Created by ithree1113 on 2023/9/11.
//

import Foundation
import RealmSwift

class LastUpdate: Object {
    @Persisted var date: Date
    
    convenience init(date: Date) {
        self.init()
        self.date = date
    }
}

let updateHistory: [(Date, [UpdateModel])] = []
