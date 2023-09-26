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
    @Persisted var potential: Int
    @Persisted var team = List<String>()
    @Persisted var ratingChangedByTeam: Map<String, Int>
    @Persisted var position = List<String>()
    @Persisted var rating = List<AttributeRecord>()
    // Bating
    @Persisted var conR = List<AttributeRecord>()
    @Persisted var conL = List<AttributeRecord>()
    @Persisted var pwrR = List<AttributeRecord>()
    @Persisted var pwrL = List<AttributeRecord>()
    @Persisted var vis = List<AttributeRecord>()
    @Persisted var disc = List<AttributeRecord>()
    @Persisted var clu = List<AttributeRecord>()
    @Persisted var bnt = List<AttributeRecord>()
    @Persisted var drgBnt = List<AttributeRecord>()
    @Persisted var dur = List<AttributeRecord>()
    // Fielding
    @Persisted var armStr = List<AttributeRecord>()
    @Persisted var armAcc = List<AttributeRecord>()
    @Persisted var fld = List<AttributeRecord>()
    @Persisted var reac = List<AttributeRecord>()
    @Persisted var blk = List<AttributeRecord>()
    // Running
    @Persisted var spd = List<AttributeRecord>()
    @Persisted var stl = List<AttributeRecord>()
    @Persisted var brAgg = List<AttributeRecord>()
    // Pitching
    @Persisted var sta = List<AttributeRecord>()
    @Persisted var h9 = List<AttributeRecord>()
    @Persisted var hr9 = List<AttributeRecord>()
    @Persisted var bb9 = List<AttributeRecord>()
    @Persisted var k9 = List<AttributeRecord>()
    @Persisted var pitClu = List<AttributeRecord>()
    @Persisted var ctrl = List<AttributeRecord>()
    @Persisted var vel = List<AttributeRecord>()
    @Persisted var brk = List<AttributeRecord>()
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    func getRecord(name: AttrName) -> [AttributeRecord] {
        guard let list = value(forKey: name.propertyKey()) as? List<AttributeRecord> else {
            return []
        }
        let sortedList = list.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        return Array(sortedList)
    }
    
    func getChange(attrName: AttrName) -> Int {
        guard let list = value(forKey: attrName.propertyKey()) as? List<AttributeRecord> else {
            return 0
        }
        let sortedList = list.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        return min(sortedList.last!.value, 99) - min(sortedList.first!.value, 99) 
    }
    
    func getFirstValue(attrName: AttrName) -> Int {
        guard let list = value(forKey: attrName.propertyKey()) as? List<AttributeRecord> else {
            return 0
        }
        let sortedList = list.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        return sortedList.first!.value
    }
    
    func getLastValue(attrName: AttrName) -> Int {
        guard let list = value(forKey: attrName.propertyKey()) as? List<AttributeRecord> else {
            return 0
        }
        let sortedList = list.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        return sortedList.last!.value
    }
}

class AttributeRecord: EmbeddedObject {
    @Persisted var date: Date
    @Persisted var value: Int
    
    convenience init(date: Date, value: Int) {
        self.init()
        self.date = date
        self.value = value
    }
}
