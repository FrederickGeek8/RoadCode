//
//  SettingsViewController.swift
//  RoadCode
//
//  Created by Frederick Morlock on 4/18/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import Foundation
import Highlightr
import ActionSheetPicker_3_0

class SettingsViewController: UITableViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let back = UIButton(type: .system)
        back.setTitle("Done", for: .normal)
        back.addTarget(self, action: #selector(done), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
        self.tableView.delegate = self
    }
    
    @objc
    func done() {
        self.dismiss(animated:true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let themes = Highlightr()?.availableThemes()
            
            let selected = themes?.firstIndex(of: UserDefaults.standard.string(forKey: "theme") ?? "vs") ?? 0
            
            ActionSheetStringPicker.show(withTitle: "Pick a Theme",
                                         rows: themes,
                                         initialSelection: selected,
                                         doneBlock:
                { picker, index, value in
                    let defaults = UserDefaults.standard
                    defaults.set(value! as! String, forKey: "theme")
            },
                                         cancel: nil,
                                         origin: self.view)
            
        }
    }
}
