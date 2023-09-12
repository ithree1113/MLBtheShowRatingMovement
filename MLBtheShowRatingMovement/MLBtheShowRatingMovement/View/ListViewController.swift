//
//  ListViewController.swift
//  MLBtheShowRatingMovement
//
//  Created by ithree1113 on 2023/9/12.
//

import UIKit

class ListViewController: UIViewController {
    
    let viewModel: ListViewModelProtocol
    
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
    }
    
    // MARK: UI
    
    // MARK: Action
}
