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
    
    func mergeUpdateHistoryIntoDatabase()
    func getPlayer(at index: Int) -> PlayerModel?
    func addFilter(field: String, delta: Int)
}

class ListViewModel: ListViewModelProtocol {
    
    var listCount: Int {
        players.count
    }
    var listUpdated: (() -> ())?
    private let realm = try! Realm()
    private let initDate = Date(string: "2023/04/21")!
    private var players: [PlayerModel] = []
    
    func mergeUpdateHistoryIntoDatabase() {
        var lastUpdate = realm.objects(LastUpdate.self)
        if lastUpdate.count == 0 {
            try! realm.write({
                realm.add(LastUpdate(date: initDate))
            })
            lastUpdate = realm.objects(LastUpdate.self)
        }
        
        updateHistory
            .sorted(by: { $0.0.compare($1.0) == .orderedAscending })
            .forEach { (date, updateList) in
                guard date.compare(lastUpdate[0].date) == .orderedDescending else {
                    return
                }
                try! realm.write({
                    lastUpdate[0].date = date
                })
                updateList.forEach { update in
                    var playerModels = realm.objects(PlayerModel.self).where { $0.name == update.name }
                    if playerModels.count == 0 {
                        createPlayerModel(at: date, from: update)
                        playerModels = realm.objects(PlayerModel.self).where { $0.name == update.name }
                    }
                    updatePlayerModel(playerModels[0], at: date, from: update)
                }
            }
    }
    
    func addFilter(field: String, delta: Int) {
        players = realm.objects(PlayerModel.self).filter { player in
            guard field.count > 0,
            let attribute = player.value(forKey: field) as? List<RatingRecord> else { return false }
            if delta >= 0 {
                return (attribute.last!.value - attribute.first!.value) >= delta
            } else  {
                return (attribute.last!.value - attribute.first!.value) <= delta
            }
        }
        listUpdated?()
    }
    
    func getPlayer(at index: Int) -> PlayerModel? {
        guard index < listCount else { return nil }
        return players[index]
    }
    
    private func createPlayerModel(at date: Date, from update: UpdateModel) {
        let player = PlayerModel(name: update.name)
        
        player.rating.append(RatingRecord(date: initDate, value: update.oldRating))
        
        update.updateItems.forEach { updateItem in
            guard let attribute = player.value(forKey: updateItem.name.rawValue) as? List<RatingRecord> else {
                return
            }
            attribute.append(RatingRecord(date: initDate, value: updateItem.getInitValue()))
        }
        try! realm.write({
            realm.add(player)
        })
    }
    
    private func updatePlayerModel(_ player: PlayerModel, at date: Date, from update: UpdateModel) {
        try! realm.write({
            player.rating.append(RatingRecord(date: date, value: update.newRating))
        })
        
        update.updateItems.forEach { updateItem in
            guard let attribute = player.value(forKey: updateItem.name.rawValue) as? List<RatingRecord> else {
                return
            }
            try! realm.write({
                attribute.append(RatingRecord(date: date, value: Int(updateItem.value)!))
            })
        }
    }
}
