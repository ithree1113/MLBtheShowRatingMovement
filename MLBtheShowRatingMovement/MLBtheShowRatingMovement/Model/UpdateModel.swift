//
//  UpdateModel.swift
//  MLBtheShowRatingMovement
//
//  Created by ithree1113 on 2023/9/11.
//

import Foundation


struct UpdateModel {
    let name: String
    let newRating: Int
    let oldRating: Int
    let updateItems: [UpdateItem]
}

struct UpdateItem {
    let name: AttrName
    let value: String
    let diff: String
    
    func getInitValue() -> Int {
        return Int(value)! + getReverse()
    }
    
    private func getReverse() -> Int {
        let prefix = diff.prefix(1)
        
        switch prefix {
        case "+":
            return 0 - (Int(diff.dropFirst(1)) ?? 0)
        case "-":
            return (Int(diff.dropFirst(1)) ?? 0)
        default:
            return 0
        }
    }
}

enum AttrName: String {
    // Bating
    case conR
    case conL
    case pwrR
    case pwrL
    case vis
    case disc
    case clu
    case bnt
    case drgBnt
    case dur
    // Fielding
    case armStr
    case armAcc
    case fld
    case reac
    case blk
    // Running
    case spd
    case stl
    case brAgg
    // Pitching
    case sta
    case h9
    case hr9
    case bb9
    case k9
    case pitClu
    case ctrl
    case vel
    case brk
}
