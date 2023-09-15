//
//  Player.swift
//  MLBtheShowRatingMovement
//
//  Created by ithree1113 on 2023/9/11.
//

import Foundation
import RealmSwift

class Player: Object {
    @Persisted(primaryKey: true) var name: String
    @Persisted var rating = List<RatingRecord>()
    // Bating
    @Persisted var conR = List<RatingRecord>()
    @Persisted var conL = List<RatingRecord>()
    @Persisted var pwrR = List<RatingRecord>()
    @Persisted var pwrL = List<RatingRecord>()
    @Persisted var vis = List<RatingRecord>()
    @Persisted var disc = List<RatingRecord>()
    @Persisted var clu = List<RatingRecord>()
    @Persisted var bnt = List<RatingRecord>()
    @Persisted var drgBnt = List<RatingRecord>()
    @Persisted var dur = List<RatingRecord>()
    // Fielding
    @Persisted var armStr = List<RatingRecord>()
    @Persisted var armAcc = List<RatingRecord>()
    @Persisted var fld = List<RatingRecord>()
    @Persisted var reac = List<RatingRecord>()
    @Persisted var blk = List<RatingRecord>()
    // Running
    @Persisted var spd = List<RatingRecord>()
    @Persisted var stl = List<RatingRecord>()
    @Persisted var brAgg = List<RatingRecord>()
    // Pitching
    @Persisted var sta = List<RatingRecord>()
    @Persisted var h9 = List<RatingRecord>()
    @Persisted var hr9 = List<RatingRecord>()
    @Persisted var bb9 = List<RatingRecord>()
    @Persisted var k9 = List<RatingRecord>()
    @Persisted var pitClu = List<RatingRecord>()
    @Persisted var ctrl = List<RatingRecord>()
    @Persisted var vel = List<RatingRecord>()
    @Persisted var brk = List<RatingRecord>()
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    func getRecord(name: AttrName) -> [RatingRecord] {
        guard let list = value(forKey: name.propertyKey()) as? List<RatingRecord> else {
            return []
        }
        let sortedList = list.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        return Array(sortedList)
    }
}

class RatingRecord: EmbeddedObject {
    @Persisted var date: Date
    @Persisted var value: Int
    
    convenience init(date: Date, value: Int) {
        self.init()
        self.date = date
        self.value = value
    }
}
