//
//  ListViewModel.swift
//  MLBtheShowRatingMovement
//
//  Created by eddiecheng on 2023/9/12.
//

import Foundation
import RealmSwift

protocol ListViewModelProtocol {
    
    var listCount: Int { get }
    var listUpdated: (() -> ())? { get set }
    
    func fetchWebDataAndWriteIntoDatabase()
    func getPlayer(at index: Int) -> Player?
    func addFilter(field: String, delta: Int)
}

class ListViewModel: ListViewModelProtocol {
    
    var listCount: Int {
        players.count
    }
    var listUpdated: (() -> ())?
    private let realm = try! Realm()
    private let initDate = Date(string: "2023/04/21")!
    private var players: [Player] = []
    
    func fetchWebDataAndWriteIntoDatabase() {
        let updatedList = realm.objects(UpdatedList.self)
        updateList
            .forEach { urlString in
                guard !updatedList.contains(where: { $0.urlString == urlString }) else {
                    return
                }
            }
        
//        updateHistory
//            .sorted(by: { $0.0.compare($1.0) == .orderedAscending })
//            .forEach { (date, updateList) in
//                guard date.compare(lastUpdate[0].date) == .orderedDescending else {
//                    return
//                }
//                try! realm.write({
//                    lastUpdate[0].date = date
//                })
//                updateList.forEach { update in
//                    var playerModels = realm.objects(PlayerModel.self).where { $0.name == update.name }
//                    if playerModels.count == 0 {
//                        createPlayer(at: date, from: update)
//                        playerModels = realm.objects(PlayerModel.self).where { $0.name == update.name }
//                    }
//                    updatePlayer(playerModels[0], at: date, from: update)
//                }
//            }
    }
    
    func addFilter(field: String, delta: Int) {
        players = realm.objects(Player.self).filter { player in
            guard field.count > 0,
            var attribute = player.value(forKey: field) as? List<RatingRecord> else { return false }
            attribute.sort(by: { $0.date.compare($1.date) == .orderedAscending })
            if delta >= 0 {
                return (attribute.last!.value - attribute.first!.value) >= delta
            } else  {
                return (attribute.last!.value - attribute.first!.value) <= delta
            }
        }
        listUpdated?()
    }
    
    func getPlayer(at index: Int) -> Player? {
        guard index < listCount else { return nil }
        return players[index]
    }
    
    private func createPlayer(at date: Date, from update: UpdateElement) {
        let player = Player(name: update.playerName)
        
        update.updatedAttributes.forEach { updatedAttribute in
            guard let attribute = player.value(forKey: updatedAttribute.name.propertyKey()) as? List<RatingRecord> else {
                return
            }
            attribute.append(RatingRecord(date: initDate, value: updatedAttribute.getInitValue()))
        }
        try! realm.write({
            realm.add(player)
        })
    }
    
    private func updatePlayer(_ player: Player, at date: Date, from update: UpdateElement) {
        update.updatedAttributes.forEach { updatedAttribute in
            guard let attribute = player.value(forKey: updatedAttribute.name.propertyKey()) as? List<RatingRecord> else {
                return
            }
            try! realm.write({
                attribute.append(RatingRecord(date: date, value: Int(updatedAttribute.value)!))
            })
        }
    }
}
