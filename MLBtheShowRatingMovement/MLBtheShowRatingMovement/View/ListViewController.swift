//
//  ListViewController.swift
//  MLBtheShowRatingMovement
//
//  Created by ithree1113 on 2023/9/12.
//

import UIKit
import SnapKit
import RealmSwift

class ListViewController: UIViewController {
    
    var viewModel: ListViewModelProtocol
    private var filterAttrName: AttrName?
    
    lazy var addingFilterBtn: UIBarButtonItem = {
        let afb = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addingFilterBtnDidTap))
        return afb
    }()
    
    lazy var searchBtn: UIBarButtonItem = {
        let sb = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchBtnDidTap))
        return sb
    }()
    
    lazy var saveBtn: UIBarButtonItem = {
        let sb = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBtnDidTap))
        return sb
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    private let lodingView: UIActivityIndicatorView = {
        let lv = UIActivityIndicatorView(style: .large)
        lv.color = .black
        return lv
    }()
    
    // MARK: Init
    init(viewModel: ListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
        viewModel.listUpdated = { [unowned self] in
            self.title = "\(viewModel.listCount)"
            tableView.reloadData()
        }
        viewModel.loadingStatusChanged = { [unowned self] isLoading in
            if isLoading {
                lodingView.startAnimating()
            } else {
                lodingView.stopAnimating()
            }
        }
        viewModel.fetchWebDataAndWriteIntoDatabase()
    }
    
    // MARK: UI
    private func initLayout() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItems = [addingFilterBtn, searchBtn]
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(lodingView)
        lodingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: Action
    @objc private func addingFilterBtnDidTap() {
        let alert = UIAlertController(title: "Movement Filter", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Attribute" }
        alert.addTextField { $0.placeholder = "Delta" }
        
        let cancalAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] action in
            self.dismiss(animated: true)
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { [unowned self] action in
            let attr = AttrName(rawValue: alert.textFields?[0].text ?? "")
            let delta = Int(alert.textFields?[1].text ?? "") ?? 0
            viewModel.addFilter(attr: attr, delta: delta)
            self.filterAttrName = attr
        })
        alert.addAction(cancalAction)
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    @objc private func searchBtnDidTap() {
        let alert = UIAlertController(title: "Player Search", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Name" }
        alert.addTextField { $0.placeholder = "Team" }
        
        let cancalAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] action in
            self.dismiss(animated: true)
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { [unowned self] action in
            if let playerName = alert.textFields?[0].text {
                viewModel.searchPlayer(name: playerName)
                self.filterAttrName = nil
            } else if let teamName = alert.textFields?[1].text, let team = Team(rawValue: teamName) {
                viewModel.searchPlayerInTeam(team)
            }
        })
        alert.addAction(cancalAction)
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    @objc private func saveBtnDidTap() {
        viewModel.savePlayersList()
    }
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        guard let player = viewModel.getPlayer(at: indexPath.row) else { return cell }
        
        var content = cell.defaultContentConfiguration()
        content.text = player.name
        let attrName: AttrName = filterAttrName ?? .rating
        let oldRating = player.rating.first!.value
        let newRating = player.rating.last!.value
        content.secondaryText = "Rating: \(oldRating) -> \(newRating)(\(newRating - oldRating))" + (attrName == .rating ? "" : " | \(attrName.rawValue): \(player.getFirstValue(attrName: attrName)) -> \(player.getLastValue(attrName: attrName))(\(player.getChange(attrName: attrName)))")
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
        guard let player = viewModel.getPlayer(at: indexPath.row) else {
            return
        }
        let detail = DetailViewController(player: player)
        navigationController?.pushViewController(detail, animated: true)
    }
}
