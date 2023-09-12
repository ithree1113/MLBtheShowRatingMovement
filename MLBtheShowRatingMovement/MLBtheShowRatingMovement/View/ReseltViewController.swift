//
//  ReseltViewController.swift
//  MLBtheShowRatingMovement
//
//  Created by ithree1113 on 2023/9/12.
//

import UIKit

class ReseltViewController: UIViewController {
    
    let viewModel: ReseltViewModelProtocol
    
    init(viewModel: ReseltViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.mergeUpdateHistoryIntoDatabase()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
