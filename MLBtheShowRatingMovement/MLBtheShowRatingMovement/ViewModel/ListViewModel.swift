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
    func searchPlayer(name: String)
    func searchPlayerInTeam(_ team: Team)
    func savePlayersList()
}

class ListViewModel: ListViewModelProtocol {
    
    typealias WebRawData = (Date, [Element], [Element])
    
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
    private var loadedCount = 0
    private lazy var unloadCount: Int = {
        let updatedUrlList = Array(realm.objects(UpdatedUrl.self).map{ $0.urlString })
        return updateList.filter { !updatedUrlList.contains($0) }.count
    }()
    
    func fetchWebDataAndWriteIntoDatabase() {
        print(realm.configuration.fileURL)
        guard unloadCount > 0 else { return }
        let updatedList = realm.objects(UpdatedUrl.self)
        loadingStatusChanged?(true)
        let queue = DispatchQueue(label: "download.serial.queue")
        updateList
            .forEach { urlString in
                guard !updatedList.contains(where: { $0.urlString == urlString }) else {
                    return
                }
                queue.async { [unowned self] in
                    do {
                        let rawData = try fetchWebData(urlString: urlString)
                        let updatePackage = try createUpdatePackage(from: rawData)
                        DispatchQueue.main.async { [unowned self] in
                            updatePackage.updateElements.forEach { updateElement in
                                var player: Player
                                if let p = realm.object(ofType: Player.self, forPrimaryKey: updateElement.playerName) {
                                    player = p
                                } else {
                                    player = createPlayer(at: updatePackage.date, from: updateElement)
                                }
                                updatePlayer(player, at: updatePackage.date, from: updateElement)
                            }
                            loadedCount += 1
                            print("\(loadedCount)/\(unloadCount)")
                            if loadedCount == unloadCount {
                                loadingStatusChanged?(false)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
    }
    
    func addFilter(attr: AttrName?, delta: Int) {
        if delta == 99 {
            batterSpecialFilter()
        } else if delta == -99 {
            pitcherSpecialFilter()
        } else {
            players = realm.objects(Player.self).filter { player in
                guard let attr = attr, player.getRecord(name: attr).count > 0 else { return false }
                if delta >= 0 {
                    return player.getChange(attrName: attr) >= delta
                } else {
                    return player.getChange(attrName: attr) <= delta
                }
            }
            .sorted(by: { player1, player2 in
                guard let attr = attr else { return false }
                if delta >= 0 {
                    return player1.getChange(attrName: attr) >= player2.getChange(attrName: attr)
                } else  {
                    return player1.getChange(attrName: attr) <= player2.getChange(attrName: attr)
                }
            })
        }

        listUpdated?()
    }
    
    func searchPlayer(name: String) {
        players = realm.objects(Player.self).where { $0.name.contains(name, options: .caseInsensitive) }.map { $0 }
        listUpdated?()
    }
    
    func searchPlayerInTeam(_ team: Team) {
        players = realm.objects(Player.self).where { $0.team.contains(team.name()) }.sorted(by: { $0.getLastValue(attrName: .rating) >= $1.getLastValue(attrName: .rating) })
        listUpdated?()
    }
    
    func getPlayer(at index: Int) -> Player? {
        guard index < listCount else { return nil }
        return players[index]
    }
    
    func savePlayersList() {
        var csvString = "Player name, Team name, Potential\n"
        let players = realm.objects(Player.self)
        players.forEach { player in
            csvString.append("\(player.name),\(player.team.first ?? ""), \n")
        }
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let filePath = path.appendingPathComponent("potential.csv")
            try csvString.write(to: filePath, atomically: true, encoding: .utf8)
            print(filePath)
        } catch {
            print(error)
        }
    }
    
    private func createPlayer(at date: Date, from update: UpdateElement) -> Player {
        let player = Player(name: update.playerName)
        
        update.updatedAttributes.forEach { updatedAttribute in
            guard let attribute = player.value(forKey: updatedAttribute.name.propertyKey()) as? List<AttributeRecord> else {
                return
            }
            attribute.append(AttributeRecord(date: initDate, value: updatedAttribute.getInitValue()))
        }
        try! realm.write({
            realm.add(player)
        })
        
        return player
    }
    
    private func updatePlayer(_ player: Player, at date: Date, from update: UpdateElement) {
        if update.teamName.count > 0, player.team.last ?? "" != update.teamName {
            try! realm.write {
                player.team.append(update.teamName )
            }
        }
        
        if update.position.count > 0 {
            try! realm.write {
                player.position.append(update.position)
            }
        }
        
        update.updatedAttributes.forEach { updatedAttribute in
            guard let attribute = player.value(forKey: updatedAttribute.name.propertyKey()) as? List<AttributeRecord> else {
                return
            }
            try! realm.write({
                if attribute.count == 0 {
                    attribute.append(AttributeRecord(date: initDate, value: updatedAttribute.getInitValue()))
                }
                attribute.append(AttributeRecord(date: date, value: Int(updatedAttribute.value)!))
                if updatedAttribute.name == .rating, let changed = Int(updatedAttribute.change) {
                    player.ratingChangedByTeam[update.teamName] = (player.ratingChangedByTeam[update.teamName] ?? 0) + changed
                }
            })
        }
    }
    
    private func fetchWebData(urlString: String) throws -> WebRawData {
        let url: URL = URLComponents(string: urlString)!.url!
        let data = try Data(contentsOf: url)
        
        guard let html = String(data: data, encoding: .utf8) else { return (Date(), [], []) }
        
        DispatchQueue.main.async { [unowned self] in
            try! realm.write({
                realm.add(UpdatedUrl(urlString: urlString))
            })
        }
        
        let document = try SwiftSoup.parse(html)
        let rawData = try document.select("tr").array().filter{ $0.children().count == 6 }.filter{ try $0.getPlayerName() != "Player" }.filter{ try $0.child(5).text().count != 0 }
        let positionData = try document.select("tr").array().filter{ $0.children().count == 1 }
        let dateString = try document.select("h2")[1].text()
        return (dateFormatter.date(from: dateString)!, rawData, positionData)
    }
    
    private func createUpdatePackage(from data: WebRawData) throws -> UpdatePackage {
        return UpdatePackage(date: data.0,
                             updateElements: try createUpdatePackageForAttribute(from: data) +
                             (try createUpdatePackageForPosition(from: data)))
    }
    
    private func createUpdatePackageForAttribute(from data: WebRawData) throws -> [UpdateElement] {
        var updateElements: [UpdateElement] = []
        for element in data.1 {
            var updatedAttributes: [UpdatedAttribute] = []
            let attrNames = try element.getUpdatedAttributeNames()
            let valueAndChange = try element.getUpdatedValueAndChange()
            for (index, attrName) in attrNames.enumerated() {
                let updatedAttribute = UpdatedAttribute(name: AttrName(rawValue: attrName)!,
                                                        value: valueAndChange[2 * index],
                                                        change: valueAndChange[2 * index + 1])
                updatedAttributes.append(updatedAttribute)
            }
            let updatedAttribute = UpdatedAttribute(name: .rating,
                                                    value: try element.getNewRating(),
                                                    change: try element.getRatingChange())
            updatedAttributes.append(updatedAttribute)
            let updateElement = UpdateElement(playerName: try element.getPlayerName(),
                                              teamName: try element.getTeamName(),
                                              position: "",
                                              updatedAttributes: updatedAttributes)
            updateElements.append(updateElement)
        }
        return updateElements
    }
    
    private func createUpdatePackageForPosition(from data: WebRawData) throws -> [UpdateElement] {
        var updateElements: [UpdateElement] = []
        for element in data.2 {
            let position = try element.select("strong")[0].text()
            let team = try element.select("strong")[1].text()
            let updateElement = UpdateElement(playerName: try element.getPlayerName(),
                                              teamName: "",
                                              position: "\(position)(\(team))",
                                              updatedAttributes: [])
            updateElements.append(updateElement)
        }
        return updateElements
    }
    
    private func batterSpecialFilter() {
        let conditions: [AttrName] = [.conR, .conL, .pwrR, .pwrL]
        let standards: [Int] = [25, 20]
        let matchCounts: [Int] = [1, 2]

        var final: Set<Player> = Set()
        for index in 0..<standards.count {
            let result = realm.objects(Player.self).filter { player in
                var matchCount = 0
                for condition in conditions {
                    if player.getRecord(name: condition).count == 0 { continue }
                    if standards[index] >= 0 {
                        if abs(player.getChange(attrName: condition)) >= standards[index] { matchCount += 1 }
                    }
                    if matchCount == matchCounts[index] { return true }
                }
                return false
            }
            final = final.union(result)
        }
        players = Array(final).sorted(by: { $0.getLastValue(attrName: .rating) >= $1.getLastValue(attrName: .rating) })
    }
    
    private func pitcherSpecialFilter() {
        let conditions: [AttrName] = [.h9, .hr9, .bb9, .k9]
        let standards: [Int] = [20, 15, 10]
        let matchCounts: [Int] = [1, 2, 3]

        var final: Set<Player> = Set()
        for index in 0..<standards.count {
            let result = realm.objects(Player.self).filter { player in
                var matchCount = 0
                for condition in conditions {
                    if player.getRecord(name: condition).count == 0 { continue }
                    if standards[index] >= 0 {
                        if abs(player.getChange(attrName: condition)) >= standards[index] { matchCount += 1 }
                    }
                    if matchCount == matchCounts[index] { return true }
                }
                return false
            }
            final = final.union(result)
        }
        players = Array(final).sorted(by: { $0.getLastValue(attrName: .rating) >= $1.getLastValue(attrName: .rating) })
    }
}

// MARK: - Element extension
fileprivate extension Element {
    func getPlayerName() throws -> String {
        if children().count == 6 {
            return try child(0).text()
        } else if children().count == 1 {
            return try select("a").text()
        } else {
           return ""
        }
    }
    
    func getTeamName() throws -> String {
        return try child(1).text()
    }
    
    func getNewRating() throws -> String {
        return try child(2).text()
    }
    
    func getRatingChange() throws -> String {
        return try child(4).text()
    }
    
    func getUpdatedAttributeNames() throws -> [String] {
        return try child(5)
            .text()
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "-", with: "")
            .components(separatedBy: .decimalDigits)
            .map { attrName in
                if let firstChar = attrName.first, firstChar == " " {
                    return String(attrName.dropFirst())
                }
                return attrName
            }
            .map { attrName in
                if let lastChar = attrName.last, lastChar == " " {
                    return String(attrName.dropLast())
                }
                return attrName
            }
            .filter { $0.count > 0 }
            .map { $0.replacingOccurrences(of: "/", with: "/9") }
    }
    
    func getUpdatedValueAndChange() throws -> [String] {
        return try child(5)
            .text()
            .replacingOccurrences(of: "/9", with: "")
            .components(separatedBy: .letters)
            .flatMap { $0.split(separator: " ") }
            .map { String($0) }
    }
}
