//
//  DetailViewController.swift
//  MLBtheShowRatingMovement
//
//  Created by EddieCheng on 2023/9/16.
//

import UIKit
import SnapKit

class DetailViewController: UIViewController {

    let player: Player
    
    init(player: Player) {
        self.player = player
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
        self.title = player.name
    }
    
    private func initLayout() {
        view.backgroundColor = .white
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
        }
        
        let teamTitle = UILabel()
        teamTitle.text = "Team"
        let teamName = UILabel()
        teamName.text = player.team.reduce("", { partialResult, teamName in
            return partialResult.count == 0 ? teamName : partialResult + " - " + teamName
        })
        let teamStack = UIStackView(arrangedSubviews: [teamTitle, teamName])
        stackView.addArrangedSubview(teamStack)
        teamTitle.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(3)
        }
        
        AttrName.allCases.forEach({ attrName in
            guard player.getRecord(name: attrName).count > 0 else {
                return
            }
            let record = player.getRecord(name: attrName)
            let title = UILabel()
            title.text = attrName.rawValue
            let change = UILabel()
            change.text = "\(record.first!.value) -> \(record.last!.value)"
            let innerStack = UIStackView(arrangedSubviews: [title, change])
            stackView.addArrangedSubview(innerStack)
            title.snp.makeConstraints { make in
                make.width.equalToSuperview().dividedBy(3)
            }
        })
    }
}
