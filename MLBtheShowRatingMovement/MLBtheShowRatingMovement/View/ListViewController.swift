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
    private var indexPath: IndexPath?
    
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
    
    private let loadingView: UIActivityIndicatorView = {
        let lv = UIActivityIndicatorView(style: .large)
        lv.color = .black
        return lv
    }()

    private lazy var searchAlert: UIAlertController = {
        let sa =  UIAlertController(title: "Player Search", message: nil, preferredStyle: .alert)
        sa.addTextField { [unowned self] textfield in
            textfield.placeholder = "Team"
            textfield.inputView = teamNamePicker
        }
        sa.addTextField { $0.placeholder = "Name" }
        
        let cancalAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] action in
            self.dismiss(animated: true)
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { [unowned self] action in
            self.filterAttrName = nil
            if let teamName = searchAlert.textFields?[0].text, teamName.count > 0 {
                viewModel.searchPlayerInTeam(teamName)
            } else if let playerName = searchAlert.textFields?[1].text {
                viewModel.searchPlayer(name: playerName)
            }
            indexPath = nil
        })
        sa.addAction(cancalAction)
        sa.addAction(confirmAction)
        return sa
    }()
    
    private lazy var teamNamePicker: UIPickerView = {
        let tnp = UIPickerView()
        tnp.dataSource = self
        tnp.delegate = self
        return tnp
    }()
    
    private lazy var filterAlert: UIAlertController = {
        let fa = UIAlertController(title: "Movement Filter", message: nil, preferredStyle: .alert)
        fa.addTextField { [unowned self] textfield in
            textfield.placeholder = "Attribute"
            textfield.inputView = attributePicker
        }
        fa.addTextField { $0.placeholder = "Delta" }
        
        let cancalAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] action in
            self.dismiss(animated: true)
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { [unowned self] action in
            let attr = AttrName(rawValue: filterAlert.textFields?[0].text ?? "")
            self.filterAttrName = attr
            let delta = Int(filterAlert.textFields?[1].text ?? "") ?? 0
            viewModel.addFilter(attr: attr, delta: delta)
            indexPath = nil
        })
        fa.addAction(cancalAction)
        fa.addAction(confirmAction)
        return fa
    }()
    
    private lazy var attributePicker: UIPickerView = {
        let ap = UIPickerView()
        ap.dataSource = self
        ap.delegate = self
        return ap
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
            if viewModel.listCount != 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        viewModel.loadingStatusChanged = { [unowned self] isLoading in
            if isLoading {
                loadingView.startAnimating()
            } else {
                loadingView.stopAnimating()
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
        
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: Action
    @objc private func addingFilterBtnDidTap() {
        present(filterAlert, animated: true)
    }
    
    @objc private func searchBtnDidTap() {
        present(searchAlert, animated: true)
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
        let oldRating = player.getFirstValue(attrName: .rating)
        let newRating = player.getLastValue(attrName: .rating)
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
        detail.delegate = self
        navigationController?.pushViewController(detail, animated: true)
        self.indexPath = indexPath
    }
}

extension ListViewController: DetailViewControllerDelegate {
    func showNextPlayer(on vc: DetailViewController) {
        guard var indexPath = self.indexPath else { return }
        indexPath.item += 1
        navigationController?.popViewController(animated: false)
        guard indexPath.item < viewModel.listCount else { return }
        tableView(tableView, didSelectRowAt: indexPath)
    }
}

// MARK: - UIPickerViewDataSource
extension ListViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === teamNamePicker {
            return Team.allCases.count + 1
        } else if pickerView === attributePicker {
            return AttrName.allCases.count
        }
        
        return 0
    }
}

// MARK: - UIPickerViewDelegate
extension ListViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === teamNamePicker {
            return row < Team.allCases.count ? Team.allCases[row].name() : ""
        } else if pickerView === attributePicker {
            return AttrName.allCases[row].rawValue
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === teamNamePicker {
            searchAlert.textFields?[0].text = row < Team.allCases.count ? Team.allCases[row].name() : nil
        } else if pickerView === attributePicker {
            filterAlert.textFields?[0].text = AttrName.allCases[row].rawValue
        }
    }
}
