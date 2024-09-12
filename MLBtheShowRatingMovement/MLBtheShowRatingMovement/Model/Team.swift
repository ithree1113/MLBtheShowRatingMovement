//
//  Team.swift
//  MLBtheShowRatingMovement
//
//  Created by eddiecheng on 2023/9/19.
//

import Foundation

enum Team: String, CaseIterable {
    case bal
    case bos
    case nyy
    case tbr
    case tor
    
    case chw
    case cle
    case det
    case kcr
    case min
    
    case hou
    case laa
    case oak
    case sea
    case tex
    
    case atl
    case mia
    case nym
    case phi
    case wsn
    
    case chc
    case cin
    case mil
    case pit
    case stl
    
    case ari
    case col
    case lad
    case sdp
    case sfg
    
    case free
    
    func name() -> String {
        switch self {
        case .bal: return "Orioles"
        case .bos: return "Red Sox"
        case .nyy: return "Yankees"
        case .tbr: return "Rays"
        case .tor: return "Blue Jays"
        case .chw: return "White Sox"
        case .cle: return "Guardians"
        case .det: return "Tigers"
        case .kcr: return "Royals"
        case .min: return "Twins"
        case .hou: return "Astros"
        case .laa: return "Angels"
        case .oak: return "Athletics"
        case .sea: return "Mariners"
        case .tex: return "Rangers"
        case .atl: return "Braves"
        case .mia: return "Marlins"
        case .nym: return "Mets"
        case .phi: return "Phillies"
        case .wsn: return "Nationals"
        case .chc: return "Cubs"
        case .cin: return "Reds"
        case .mil: return "Brewers"
        case .pit: return "Pirates"
        case .stl: return "Cardinals"
        case .ari: return "Diamondbacks"
        case .col: return "Rockies"
        case .lad: return "Dodgers"
        case .sdp: return "Padres"
        case .sfg: return "Giants"
        case .free: return "Free Agents"
        }
    }
}
