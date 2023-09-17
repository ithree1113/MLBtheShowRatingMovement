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
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(20)
        }
        
        AttrName.allCases.forEach({ attrName in
            guard player.getRecord(name: attrName).count > 0 else {
                return
            }
            let record = player.getRecord(name: attrName)
            let title = UILabel()
            title.text = attrName.rawValue
            title.textColor = attrName.rawValue == "Rating" ? UIColor(red: 46.0/255.0, green: 169.0/255.0, blue: 223.0/255.0, alpha: 1) : .black
            let changeLabel = UILabel()
            let change = player.getChange(attrName: attrName)
            changeLabel.text = "\(record.first!.value) -> \(record.last!.value)(\(change))"
            changeLabel.textColor = change >= 0 ? UIColor(red: 0, green: 170.0/255.0, blue: 144.0/255.0, alpha: 1) : UIColor(red: 203.0/255.0, green: 27.0/255.0, blue: 69.0/255.0, alpha: 1)
            let innerStack = UIStackView(arrangedSubviews: [title, changeLabel])
            stackView.addArrangedSubview(innerStack)
            title.snp.makeConstraints { make in
                make.width.equalToSuperview().dividedBy(3)
            }
        })
    }
}
