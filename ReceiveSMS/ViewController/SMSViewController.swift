//
//  SMSViewController.swift
//  ReceiveSMS
//
//  Created by Trung on 22/08/2023.
//

import UIKit
import SwiftSoup
import Toast
import JGProgressHUD
class SMSViewController:UIViewController, UITableViewDelegate, UITableViewDataSource{
    var progressHUD: JGProgressHUD?
    
    @IBOutlet weak var smstableView: UITableView!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    var cellDataArray : [CellModel] = []
    var number:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        smstableView.delegate = self
        smstableView.dataSource = self
        let backButtonImage = UIImage(named: "backarrow")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        backButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10) 
        let nib = UINib(nibName: "SMSCell", bundle: nil)
        smstableView.register(nib, forCellReuseIdentifier: SMSCell.identifier)
        DispatchQueue.main.async {
            self.showLoadingHUD()
        }
        fetchDataForNumber()
        DispatchQueue.main.async {
            self.hideLoadingHUD()
        }
    }
    
    func fetchDataForNumber(){
        let urlString = "https://receive-smss.com/sms/\(number)/"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                
                if let data = data {
                    do {
                        let html = String(data: data, encoding: .utf8)
                        let doc = try SwiftSoup.parse(html ?? "")
                        
                        let trElements = try doc.select("tr")
                        
                        for trElement in trElements {
                            let tdElements = try trElement.select("td.wr3pc32233el1878")
                            
                            if tdElements.size() >= 3 {
                                let sender = try tdElements.get(0).text()
                                let content = try tdElements.get(1).text()
                                let time = try tdElements.get(2).text()
                                
                                let cellData = CellModel(sender: sender, content: content, time: time)
                                
                                DispatchQueue.main.async {
                                    self?.cellDataArray.append(cellData)
                                    self?.smstableView.reloadData()
                                }
                            }
                        }
                    } catch {
                        print("Error parsing HTML: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    
    
    @IBAction func copyTapped(_ sender: Any) {
        let numberCopy = number
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = numberCopy
        showToast(message: "Number Copied Into You Clipboard")
        UserDefaults.standard.setValue(number, forKey: "numberRecent")
    }
    
    @IBAction func reloadTapped(_ sender: Any) {
        cellDataArray.removeAll()
        smstableView.reloadData()
        DispatchQueue.main.async {
            self.showLoadingHUD()
        }
        fetchDataForNumber()
        DispatchQueue.main.async {
            self.hideLoadingHUD()
        }
    }
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    private func showToast(message :String){
        self.view.makeToast(message, duration: 2.0, position: .bottom)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = cellDataArray[indexPath.row]
        let cell = smstableView.dequeueReusableCell(withIdentifier: SMSCell.identifier, for: indexPath) as! SMSCell
        cell.senderLabel.text = cellModel.sender
        cell.contentLabel.text = cellModel.content
        cell.timeLabel.text = cellModel.time
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    func showLoadingHUD(){
        progressHUD = JGProgressHUD(style: .dark)
        progressHUD?.textLabel.text = "Loading..."
        progressHUD?.show(in: self.view)
    }
    func hideLoadingHUD(){
        progressHUD?.dismiss()
        progressHUD = nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        smstableView.deselectRow(at: indexPath, animated: true)
    }
}
