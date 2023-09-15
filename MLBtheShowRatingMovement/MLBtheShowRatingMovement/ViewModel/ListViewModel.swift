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
    var loadingStatusChanged: ((Bool) -> ())? { get set }
    
    func fetchWebDataAndWriteIntoDatabase()
    func getPlayer(at index: Int) -> Player?
    func addFilter(attr: AttrName?, delta: Int)
}

class ListViewModel: ListViewModelProtocol {
    
    var listCount: Int {
        players.count
    }
    var listUpdated: (() -> ())?
    var loadingStatusChanged: ((Bool) -> ())?
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
        loadingStatusChanged?(true)
        updateList
            .forEach { urlString in
                guard !updatedList.contains(where: { $0.urlString == urlString }) else {
                    return
                }
                Task {
                    do {
                        let rawData = try await fetchWebData(urlString: urlString)
                        
                        let updatePackage = try createUpdatePackage(from: rawData)
                        updatePackage.updateElements.forEach { updateElement in
                            var players = realm.objects(Player.self).where { $0.name == updateElement.playerName }
                            if players.count == 0 {
                                createPlayer(at: updatePackage.date, from: updateElement)
                                players = realm.objects(Player.self).where { $0.name == updateElement.playerName }
                            }
                            updatePlayer(players[0], at: updatePackage.date, from: updateElement)
                        }
                        loadingStatusChanged?(false)
                    } catch {
                        print(error)
                    }
                }
                try! realm.write({
                    realm.add(UpdatedList(urlString: urlString))
                })
            }
    }
    
    func addFilter(attr: AttrName?, delta: Int) {
        players = realm.objects(Player.self).filter { player in
            guard let attr = attr else { return false }
            let attrRecord = player.getRecord(name: attr)
            if delta >= 0 {
                return (attrRecord.last!.value - attrRecord.first!.value) >= delta
            } else  {
                return (attrRecord.last!.value - attrRecord.first!.value) <= delta
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
    
    private func createUpdatePackage(from data: (Date, [Element])) throws -> UpdatePackage {
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
                var attrNameVar = attrName
                if attrNameVar == "CLU" {
                    let suffix = try element.child(5).select("div")[4 * index + 4].attr("class").suffix(6)
                    if suffix == "Orange" {
                        attrNameVar = "PIT CLU"
                    }
                }
                let updatedAttribute = UpdatedAttribute(name: AttrName(rawValue: attrNameVar)!,
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
        
        return UpdatePackage(date: data.0, updateElements: updateElements)
    }
}
