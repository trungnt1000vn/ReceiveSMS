//
//  SettingViewController.swift
//  ReceiveSMS
//
//  Created by Trung on 31/08/2023.
//

import UIKit
import Toast

class SettingViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var premiumLabel: UILabel!
    @IBOutlet weak var advantagesLabel: UILabel!
    @IBOutlet weak var lineBGImage: UIImageView!
    @IBOutlet weak var settingTableView: UITableView!
    
    var settingitem :[String] = ["Feedback", "Rate us", "Share this app"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.overrideUserInterfaceStyle = .light
        settingTableView.dataSource = self
        settingTableView.delegate = self
        settingTableView.separatorStyle = .none
        let nib = UINib(nibName: "SettingTableViewCell", bundle: nil)
        settingTableView.register(nib, forCellReuseIdentifier: SettingTableViewCell.identifier)
        let backButtonImage = UIImage(named: "backarrow")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        backButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingTableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as! SettingTableViewCell
        cell.label.text = settingitem[indexPath.row]
        cell.iconImage.image = UIImage(named: settingitem[indexPath.row].lowercased())
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingitem.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingTableView.deselectRow(at: indexPath, animated:  true)
        showToast(message: "Coming soon...")
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
}
extension SettingViewController {
    private func showToast(message :String){
        self.view.makeToast(message, duration: 2.0, position: .bottom)
    }
    @objc func showToastObjectC(){
        showToast(message: "Coming soon...")
    }
    private func setUpPremium() {
        let gesture = UIGestureRecognizer(target: self, action: #selector(showToastObjectC))
        backgroundImage.addGestureRecognizer(gesture)
        premiumLabel.addGestureRecognizer(gesture)
        advantagesLabel.addGestureRecognizer(gesture)
        lineBGImage.addGestureRecognizer(gesture)
    }
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
