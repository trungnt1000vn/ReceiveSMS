//
//  CountryViewController.swift
//  ReceiveSMS
//
//  Created by Trung on 22/08/2023.
//

import UIKit
import SwiftSoup
import Toast
class CountryViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var cellDataArray: [CellData] = []
    var originalCellDataArray: [CellData] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var BG1: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var textFiled: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        textFiled.layer.borderWidth = 0.3
        textFiled.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        textFiled.layer.cornerRadius = 20
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        imageView.contentMode = .scaleAspectFit
        BG1.contentMode = .scaleAspectFill
        BG1.image = UIImage(named: "BG1")
        let nib = UINib(nibName: "TableCell", bundle: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(numberLabelTapped))
        numberLabel.isUserInteractionEnabled = true
        numberLabel.addGestureRecognizer(tapGesture)
        setUpRecent()
        tableView.register(nib, forCellReuseIdentifier: TableCell.identifier)
        fetchData()
    }
    func fetchData(){
        let urlString = "https://receive-smss.com/"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error loading data: \(error)")
                    return
                }
                
                if let html = String(data: data, encoding: .utf8) {
                    do {
                        let doc = try SwiftSoup.parse(html)
                         
                        let countryElements = try doc.select("div.number-boxes-item-country")
                        
                        for countryElement in countryElements {
                            let countryText = try countryElement.text()
                            let imageUrl = try countryElement.select("img").attr("src")
                            
                            if !self.cellDataArray.contains(where: { $0.countryName == countryText }) {
                                let cellData = CellData(imageUrl: imageUrl, countryName: countryText)
                                self.cellDataArray.append(cellData)
                            }
                        }
                        DispatchQueue.main.async {
                            self.originalCellDataArray = self.cellDataArray
                            self.tableView.reloadData()
                        }
                    } catch {
                        print("Error parsing HTML: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func numberLabelTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "smsvc") as? SMSViewController{
            vc.navigationItem.largeTitleDisplayMode = .never
            guard let number = numberLabel.text else {
                return
            }
            vc.number = number
            vc.title = number
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        let content = numberLabel.text
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = content
        showToast(message: "Number has been copied into clipboard ")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            cellDataArray = originalCellDataArray
            tableView.reloadData()
            return
        }
        
        cellDataArray = originalCellDataArray.filter { $0.countryName.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let vc = storyboard?.instantiateViewController(withIdentifier: "NumbersViewController") as? NumbersViewController {
            vc.navigationItem.largeTitleDisplayMode = .never
            let cellData = cellDataArray[indexPath.row]
            let countryName = cellData.countryName
            vc.country = countryName
            UserDefaults.standard.setValue(countryName, forKey: "countryRecent")
            UserDefaults.standard.setValue("No number yet", forKey: "numberRecent")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableCell.identifier, for: indexPath) as! TableCell
        let cellData = cellDataArray[indexPath.row]
        cell.countryLabel.text = cellData.countryName
        cell.iconImage.image = UIImage(named: cellData.countryName.lowercased())
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    public func setUpRecent(){
        guard let country = UserDefaults.standard.value(forKey: "countryRecent") as? String, let number = UserDefaults.standard.value(forKey: "numberRecent") as? String
        else {
            print("Haven't got country and number recent yet !")
            return
        }
        countryLabel.text = country
        numberLabel.text = number
        imageView.image = UIImage(named: country.lowercased())
    }
}
extension CountryViewController {
    private func showToast(message: String){
        self.view.makeToast(message, duration: 2.0, position: .bottom)
    }
}
