//
//  UpdateElement.swift
//  MLBtheShowRatingMovement
//
//  Created by ithree1113 on 2023/9/11.
//

import Foundation

struct UpdatePackage {
    let date: Date
    let updateElements: [UpdateElement]
}

struct UpdateElement {
    let playerName: String
    let position: String
    let updatedAttributes: [UpdatedAttribute]
}

struct UpdatedAttribute {
    let name: AttrName
    let value: String
    let change: String
    
    init(name: AttrName, value: String, change: String) {
        self.name = name
        self.value = value
        self.change = change
    }
    
    func getInitValue() -> Int {
        return Int(value)! + getReverse()
    }
    
    private func getReverse() -> Int {
        return -Int(change)!
    }
}

enum AttrName: String, CaseIterable {
    case rating = "Rating"
    // Bating
    case conR = "CON R"
    case conL = "CON L"
    case pwrR = "PWR R"
    case pwrL = "PWR L"
    case vis = "VIS"
    case disc = "DISC"
    case clu = "CLU"
    case bnt = "BNT"
    case drgBnt = "DRG BNT"
    case dur = "DUR"
    // Fielding
    case armStr = "ARM STR"
    case armAcc = "ARM ACC"
    case fld = "FLD"
    case reac = "REAC"
    case blk = "BLK"
    // Running
    case spd = "SPD"
    case stl = "STL"
    case brAgg = "BR AGG"
    // Pitching
    case sta = "STA"
    case h9 = "H/9"
    case hr9 = "HR/9"
    case bb9 = "BB/9"
    case k9 = "K/9"
    case pitClu = "PIT CLU"
    case ctrl = "CTRL"
    case vel = "VEL"
    case brk = "BRK"
    
    func propertyKey() -> String {
        switch self {
        case .rating: return "rating"
        case .conR: return "conR"
        case .conL: return "conL"
        case .pwrR: return "pwrR"
        case .pwrL: return "pwrL"
        case .vis: return "vis"
        case .disc: return "disc"
        case .clu: return "clu"
        case .bnt: return "bnt"
        case .drgBnt: return "drgBnt"
        case .dur: return "dur"
        case .armStr: return "armStr"
        case .armAcc: return "armAcc"
        case .fld: return "fld"
        case .reac: return "reac"
        case .blk: return "blk"
        case .spd: return "spd"
        case .stl: return "stl"
        case .brAgg: return "brAgg"
        case .sta: return "sta"
        case .h9: return "h9"
        case .hr9: return "hr9"
        case .bb9: return "bb9"
        case .k9: return "k9"
        case .pitClu: return "pitClu"
        case .ctrl: return "ctrl"
        case .vel: return "vel"
        case .brk: return "brk"
        }
    }
}
