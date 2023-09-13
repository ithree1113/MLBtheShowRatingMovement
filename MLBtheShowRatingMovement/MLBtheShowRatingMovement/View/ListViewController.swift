//
//  ListViewController.swift
//  MLBtheShowRatingMovement
//
//  Created by ithree1113 on 2023/9/12.
//

import UIKit
import SnapKit

class ListViewController: UIViewController {
    
    let viewModel: ListViewModelProtocol
    
    lazy var addingFilterBtn: UIBarButtonItem = {
        let afb = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addingFilterBtnDidTap))
        return afb
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    // MARK: Init
    init(viewModel: ListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.mergeUpdateHistoryIntoDatabase()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
    }
    
    // MARK: UI
    private func initLayout() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = addingFilterBtn
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaInsets)
        }
    }
    
    // MARK: Action
    @objc private func addingFilterBtnDidTap() {
    }
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        guard let player = viewModel.getPlayer(at: indexPath.row) else { return cell }
        
        var content = cell.defaultContentConfiguration()
        content.text = player.name
        content.secondaryText = "\(player.rating.first!.value) -> \(player.rating.last!.value)"
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listCount
    }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
