//
//  ListViewModel.swift
//  MLBtheShowRatingMovement
//
//  Created by eddiecheng on 2023/9/12.
//

import Foundation
import RealmSwift
import SwiftSoup

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
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMMM dd, yyyy"
        return df
    }()
    
    @MainActor
    func fetchWebDataAndWriteIntoDatabase() {
        print(realm.configuration.fileURL)
        let updatedList = realm.objects(UpdatedList.self)
        updateList
            .forEach { urlString in
                guard !updatedList.contains(where: { $0.urlString == urlString }) else {
                    return
                }
                Task {
                    do {
                        let rawData = try await fetchWebData(urlString: urlString)
                        let updateData = try createUpdateData(from: rawData)
                        updateData.1.forEach { update in
                            var players = realm.objects(Player.self).where { $0.name == update.playerName }
                            if players.count == 0 {
                                createPlayer(at: updateData.0, from: update)
                                players = realm.objects(Player.self).where { $0.name == update.playerName }
                            }
                            updatePlayer(players[0], at: updateData.0, from: update)
                        }
                    } catch {
                        print(error)
                    }
                }
                try! realm.write({
                    realm.add(UpdatedList(urlString: urlString))
                })
            }
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
    
    private func fetchWebData(urlString: String) async throws -> (Date, [Element]) {
        let url: URL = URLComponents(string: urlString)!.url!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let html = String(data: data, encoding: .utf8) else { return (Date(), []) }
        let document = try SwiftSoup.parse(html)
        let rawData = try document.select("tr").array().filter{ $0.children().count == 6 }.filter{ try $0.child(0).text() != "Player" }.filter{ try $0.child(5).text().count != 0 }
        let dateString = try document.select("h2")[1].text()
        return (dateFormatter.date(from: dateString)!, rawData)
    }
    
    private func createUpdateData(from data: (Date, [Element])) throws -> (Date, [UpdateElement]) {
        var updateElements: [UpdateElement] = []
        for element in data.1 {
            var updatedAttributes: [UpdatedAttribute] = []
            let attrNames = try element.child(5).text().components(separatedBy: .decimalDigits).filter { $0.count > 2 }.map { attrName in
                var attrNameVar = attrName
                if let first = attrNameVar.first, first == " " {
                    attrNameVar.removeFirst()
                }
                if let last = attrNameVar.last, last == " " {
                    attrNameVar.removeLast()
                }
                return String(attrNameVar)
            }
            let valueAndChange = try element.child(5).text().components(separatedBy: .letters).filter { $0.count > 1 }.flatMap { $0.split(separator: " ") }
            for (index, attrName) in attrNames.enumerated() {
                let updatedAttribute = UpdatedAttribute(name: AttrName(rawValue: attrName)!,
                                                        value: String(valueAndChange[2 * index + 1]),
                                                        change: String(valueAndChange[2 * index + 1]))
                updatedAttributes.append(updatedAttribute)
            }
            let updatedAttribute = UpdatedAttribute(name: .rating,
                                                    value: try element.child(2).text(),
                                                    change: try element.child(4).text())
            updatedAttributes.append(updatedAttribute)
            let updateElement = UpdateElement(playerName: try element.child(0).text(), updatedAttributes: updatedAttributes)
            updateElements.append(updateElement)
        }
        
        return (data.0, updateElements)
    }
}
