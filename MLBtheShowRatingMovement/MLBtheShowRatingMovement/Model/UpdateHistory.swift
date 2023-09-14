//
//  UpdateHistory.swift
//  MLBtheShowRatingMovement
//
//  Created by ithree1113 on 2023/9/11.
//

import Foundation
import RealmSwift

class LastUpdate: Object {
    @Persisted var date: Date
    
    convenience init(date: Date) {
        self.init()
        self.date = date
    }
}

let updateHistory: [(Date, [UpdateModel])] = []
/*
 override func viewDidLoad() {
     super.viewDidLoad()
     
     Task {
         do {
             try await fetchData()
         } catch {
             print(error)
         }
     }
 }

 private func fetchData() async throws {
     let url: URL = URLComponents(string: "https://mlb23.theshow.com/roster_updates/7")!.url!
     let (data, _) = try await URLSession.shared.data(from: url)
     
     guard let html = String(data: data, encoding: .utf8) else { return }
     let document = try SwiftSoup.parse(html)
     let links: [Element] = document.select("tr").array().filter{ $0.children().count == 6 }.filter{ try $0.child(0).text() != "Player" }
 }
 
 let dateFormatter = DateFormatter()
 dateFormatter.dateFormat = "MMMM dd, yyyy"
 let dateString = try document.select("h2")[1].text()
 let date = dateFormatter.date(from: dateString)
 
 po try document.select("tr")[1]
 Element <tr>
  <td> <a href="/items/f1105c2f23b2c673114e6c8a16b135b2">Shohei Ohtani</a> </td>
  <td>Angels</td>
  <td> <img class="icons-rarity" src="https://mlb23.theshow.com/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBbWJTIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--0302100e855dca83eecb9f3eba5ec4c6cf645449/shield-diamond.webp"> 96 </td>
  <td> <img class="icons-rarity" src="https://mlb23.theshow.com/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBbWJTIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--0302100e855dca83eecb9f3eba5ec4c6cf645449/shield-diamond.webp"> 96 </td>
  <td>0</td>
  <td>
   <div class="player-attr-row player-attr-row-nowrap">
    <div class="player-attr-box">
     <div class="player-attr-name player-attr-name-orange">
      H/9
     </div>
     <div class="player-attr-number">
       108
      <div class="player-attr-change player-attr-change-green">
        +5
      </div>
     </div>
    </div>
    <div class="player-attr-box">
     <div class="player-attr-name player-attr-name-orange">
      BB/9
     </div>
     <div class="player-attr-number">
       56
      <div class="player-attr-change player-attr-change-red">
        -7
      </div>
     </div>
    </div>
    <div class="player-attr-box">
     <div class="player-attr-name player-attr-name-orange">
      CLU
     </div>
     <div class="player-attr-number">
       106
      <div class="player-attr-change player-attr-change-red">
        -9
      </div>
     </div>
    </div>
   </div> </td>
 </tr>

 (lldb) po try document.select("tr")[1].child(0)
 Element <td> <a href="/items/f1105c2f23b2c673114e6c8a16b135b2">Shohei Ohtani</a> </td>

 (lldb) po try document.select("tr")[1].child(1)
 Element <td>Angels</td>

 (lldb) po try document.select("tr")[1].child(2)
 Element <td> <img class="icons-rarity" src="https://mlb23.theshow.com/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBbWJTIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--0302100e855dca83eecb9f3eba5ec4c6cf645449/shield-diamond.webp"> 96 </td>

 (lldb) po try document.select("tr")[1].child(0).text()
 "Shohei Ohtani"

 (lldb) po try document.select("tr")[1].child(2).text()
 "96"

 (lldb) po try document.select("tr")[1].children().count
 6

 (lldb) po try document.select("tr")[1].child(3).text()
 "96"

 (lldb) po try document.select("tr")[1].child(4).text()
 "0"

 (lldb) po try document.select("tr")[1].child(5).text()
 "H/9 108 +5 BB/9 56 -7 CLU 106 -9"

 (lldb) po try document.select("tr")[1].child(5).text().components(separatedBy: [" "])
 ▿ 9 elements
   - 0 : "H/9"
   - 1 : "108"
   - 2 : "+5"
   - 3 : "BB/9"
   - 4 : "56"
   - 5 : "-7"
   - 6 : "CLU"
   - 7 : "106"
   - 8 : "-9"
 */
