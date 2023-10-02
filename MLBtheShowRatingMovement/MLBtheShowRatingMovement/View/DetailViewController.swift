//
//  DetailViewController.swift
//  MLBtheShowRatingMovement
//
//  Created by EddieCheng on 2023/9/16.
//

import UIKit
import SnapKit
import RealmSwift

class DetailViewController: UIViewController {

    let player: Player
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()
    private lazy var potentialTextField: UITextField = {
        let ptf = UITextField()
        ptf.text = "\(player.potential)"
        ptf.layer.borderColor = UIColor.clear.cgColor
        ptf.delegate = self
        return ptf
    }()
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        try! Realm().write({
            if let potential = Int(potentialTextField.text ?? "0") {
                player.potential = potential
            }
        })
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
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(20)
        }
        
        let potentialTitle = UILabel()
        potentialTitle.text = "Potential"
        addArrangedSubviews(title: potentialTitle, content: potentialTextField)

        let teamTitle = UILabel()
        teamTitle.text = "Team"
        let teamName = UILabel()
        teamName.numberOfLines = 0
        teamName.text = player.team.reduce("", { $0.count == 0 ? $1 + "(\(String(describing: player.ratingChangedByTeam[$1]!)))" : $0 + " -> \($1)(\(String(describing: player.ratingChangedByTeam[$1]!)))"})
        addArrangedSubviews(title: teamTitle, content: teamName)
        
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
            addArrangedSubviews(title: title, content: changeLabel)
        })
        
        let positionChange = player.position.reduce("", { $0.count == 0 ? $1 : $0 + " -> \($1)"})
        if positionChange.count > 0 {
            let positionTitle = UILabel()
            positionTitle.numberOfLines = 2
            positionTitle.text = "Position\nChange"
            let positionContent = UILabel()
            positionContent.numberOfLines = 0
            positionContent.text = player.position.reduce("", { $0.count == 0 ? $1 : $0 + " -> \($1)"})
            addArrangedSubviews(title: positionTitle, content: positionContent)
        }
    }
    
    private func addArrangedSubviews<T: UIView>(title: UILabel, content: T) {
        let innerStack = UIStackView(arrangedSubviews: [title, content])
        stackView.addArrangedSubview(innerStack)
        title.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(3)
        }
    }
}

// MARK: - UITextFieldDelegate
extension DetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text, text == "0" {
            textField.text = ""
        }
    }
}
