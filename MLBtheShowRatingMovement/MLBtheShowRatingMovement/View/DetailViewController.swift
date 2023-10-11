//
//  DetailViewController.swift
//  MLBtheShowRatingMovement
//
//  Created by EddieCheng on 2023/9/16.
//

import UIKit
import SnapKit
import RealmSwift

protocol DetailViewControllerDelegate: AnyObject {
    func showNextPlayer(on vc: DetailViewController)
}

class DetailViewController: UIViewController {

    weak var delegate: DetailViewControllerDelegate?
    private let player: Player
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
    private lazy var nextBtn: UIBarButtonItem = {
        let nb = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextBtnDidTap))
        
        return nb
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
        navigationItem.rightBarButtonItem = nextBtn
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
            guard player.getRecord(name: attrName).count > 0, attrName != .rating else {
                return
            }
            let title = UILabel()
            title.text = attrName.rawValue
            let changeLabel = UILabel()
            changeLabel.text = "\(player.getLastValue(attrName: attrName))"
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
    
    @objc private func nextBtnDidTap() {
        delegate?.showNextPlayer(on: self)
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
