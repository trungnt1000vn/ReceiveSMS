//
//  NumbersViewController.swift
//  ReceiveSMS
//
//  Created by Trung on 22/08/2023.
//

import UIKit
import SwiftSoup
import JGProgressHUD
import SDWebImage

class NumbersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var numbertableView: UITableView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var bgOpacity: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countingLabel: UILabel!
    @IBOutlet weak var countryIcon: UIImageView!
    @IBOutlet weak var goProBtn: UIButton!
    
    
    var progressHUD: JGProgressHUD?
    var country: String = ""
    var phoneNumberData: [String] = []
    var timeData: [String] = []
    var phoneNumberCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.overrideUserInterfaceStyle = .light
        numbertableView.dataSource = self
        numbertableView.delegate = self
        countryLabel.text = country
        countingLabel.text = "\(phoneNumberData.count) numbers"
        //countryIcon.image = UIImage(named: country.lowercased())
        textField.layer.borderWidth = 0.3
        textField.layer.cornerRadius = 15
        countryIcon.contentMode = .scaleToFill
        coverImage.contentMode = .scaleAspectFill
        bgOpacity.contentMode = .scaleAspectFill
        //coverImage.image = UIImage(named: "\(country.lowercased()) cover")
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        self.view.addGestureRecognizer(panGesture)
        
        let backButtonImage = UIImage(named: "backarrow")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        let settingButtonImage = UIImage(named: "settingiconMain")?.withRenderingMode(.alwaysOriginal)
        let settingButton = UIBarButtonItem(image: settingButtonImage, style: .plain, target: self, action: #selector(settingButtonTapped))
        navigationItem.rightBarButtonItem = settingButton
        settingButton.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        backButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        let nib = UINib(nibName: "NumbersViewCell", bundle: nil)
        numbertableView.register(nib, forCellReuseIdentifier: NumbersViewCell.identifier)
        DispatchQueue.main.async {
            self.showLoadingHUD()
        }
        fetchDataForCountry()
        DispatchQueue.main.async {
            self.hideLoadingHUD()
        }
        
    }
    
    @IBAction func goProTapped(_ sender: Any) {
        
    }
    
    
    @objc func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            // Bắt đầu chuyển động
            break
        case .changed:
            // Xử lý chuyển động
            let progress = translation.x / view.bounds.width
            updateInteractiveTransition(progress)
        case .ended, .cancelled:
            // Kết thúc chuyển động
            let velocity = gesture.velocity(in: view)
            let progress = translation.x / view.bounds.width
            if velocity.x > 0 {
                if let navigationController = navigationController {
                    if progress > 0.5 || velocity.x > 1000 {
                        finishInteractiveTransition()
                    } else {
                        cancelInteractiveTransition()
                    }
                }
            } else {
                cancelInteractiveTransition()
            }
        default:
            break
        }
    }

    private func updateInteractiveTransition(_ percentComplete: CGFloat) {
        guard let navigationController = navigationController else {
            return
        }
        
        let targetView = navigationController.view!
        let fromView = navigationController.viewControllers[navigationController.viewControllers.count - 2].view!
        
        let screenWidth = UIScreen.main.bounds.width
        let targetViewEndFrame = CGRect(x: 0, y: 0, width: screenWidth, height: targetView.bounds.height)
        let fromViewEndFrame = CGRect(x: -screenWidth * percentComplete, y: 0, width: screenWidth, height: fromView.bounds.height)
        
        targetView.frame = targetViewEndFrame
        fromView.frame = fromViewEndFrame
    }

    private func finishInteractiveTransition() {
        guard let navigationController = navigationController else {
            return
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let targetViewEndFrame = CGRect(x: 0, y: 0, width: screenWidth, height: navigationController.view.bounds.height)
        let fromViewEndFrame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: navigationController.view.bounds.height)
        
        UIView.animate(withDuration: 0.3, animations: {
            navigationController.view.frame = targetViewEndFrame
            navigationController.viewControllers[navigationController.viewControllers.count - 2].view.frame = fromViewEndFrame
        }) { (_) in
            navigationController.popViewController(animated: false)
            navigationController.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: navigationController.view.bounds.height)
        }
    }

    private func cancelInteractiveTransition() {
        guard let navigationController = navigationController else {
            return
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let targetViewEndFrame = CGRect(x: 0, y: 0, width: screenWidth, height: navigationController.view.bounds.height)
        let fromViewEndFrame = CGRect(x: 0, y: 0, width: screenWidth, height: navigationController.view.bounds.height)
        
        UIView.animate(withDuration: 0.3, animations: {
            navigationController.view.frame = targetViewEndFrame
            navigationController.viewControllers[navigationController.viewControllers.count - 2].view.frame = fromViewEndFrame
        }) { (_) in
            navigationController.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: navigationController.view.bounds.height)
        }
    }

    private func animateTransition(from fromView: UIView, to toView: UIView) {
        let screenWidth = UIScreen.main.bounds.width
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: fromView.bounds.height))
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        
        toView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: fromView.bounds.height)
        
        UIView.animate(withDuration: 0.3, animations: {
            fromView.frame = CGRect(x: -screenWidth, y: 0, width: screenWidth, height: fromView.bounds.height)
            toView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: fromView.bounds.height)
        }) { (_) in
            fromView.removeFromSuperview()
            containerView.removeFromSuperview()
        }
    }
    func fetchDataForCountry() {
        let urlString = "https://receive-smss.com/"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error loading data: \(String(describing: error))")
                    return
                }
                
                if let html = String(data: data, encoding: .utf8) {
                    do {
                        let doc = try SwiftSoup.parse(html)
                        
                        let countryElements = try doc.select("div.number-boxes-item-country")
                        
                        for countryElement in countryElements {
                            let countryText = try countryElement.text()
                            if countryText == self.country {
                                
                                if let phoneNumber = try countryElement.parent()?.select("div.number-boxes-itemm-number").first()?.text() {
                                    self.phoneNumberData.append(phoneNumber)
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.phoneNumberCount = self.phoneNumberData.count
                            self.countingLabel.text = "\(self.phoneNumberCount) numbers"
                            let countryUse = self.country.lowercased()
                            let filename = "\(countryUse) cover.png"
                            let path = "coverphotos/\(filename)"
                            StorageManager.shared.downloadURL(for: path, completion: { result in
                                switch result {
                                case .success(let url):
                                    self.coverImage.sd_setImage(with: url, completed: nil)
                                case .failure(let error):
                                    print("Failed to download the image : \(error)")
                                }
                            })
                            let fileNameicon = "\(countryUse)"
                            let pathIcon = "countriesphotos/\(countryUse).png"
                            StorageManager.shared.downloadURL(for: pathIcon, completion: { result in
                                switch result{
                                case .success(let url):
                                    self.countryIcon.sd_setImage(with: url, completed: nil)
                                case .failure(let error):
                                    print("Failed to download the icon image : \(error)")
                                }
                            })
                            self.numbertableView.reloadData()
                            self.hideLoadingHUD()
                        }
                    } catch {
                        print("Error parsing HTML: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    func fetchTime(number: String) -> String{
        var time: String = ""
        let urlString = "https://receive-smss.com/sms/\(number)"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let html = String(data: data, encoding: .utf8)
                        let doc = try SwiftSoup.parse(html ?? "")
                        
                        
                        let trElements = try doc.select("tr")
                        
                        if let firstTr = trElements.first() {
                            
                            let tdElements = try firstTr.select("td.wr3pc32233el1878")
                            if tdElements.size() >= 3 {
                                let thirdTd = try tdElements.get(2)
                                let content = try thirdTd.text()
                                print("Content of third td: \(content)")
                                time = content
                            }
                        }
                    } catch {
                        print("Error parsing HTML: \(error)")
                    }
                }
            }
            task.resume()
        }
        return time
    }
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc func settingButtonTapped(){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "settingviewcontroller") as? SettingViewController {
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.title = "Setting"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneNumberCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NumbersViewCell", for: indexPath) as! NumbersViewCell
        cell.numberLabel.text = phoneNumberData[indexPath.row]
        cell.iconImage.image = UIImage(named: "phoneicon")
        cell.rightArrow.image = UIImage(named: "nextbutton")
        let number = phoneNumberData[indexPath.row]
        cell.timeLabel.text = fetchTime(number: number)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let vc = storyboard?.instantiateViewController(withIdentifier: "smsvc") as? SMSViewController{
            vc.navigationItem.largeTitleDisplayMode = .never
            let cellData = phoneNumberData[indexPath.row]
            let number = String(cellData.dropFirst())
            vc.number = number
            vc.title = "Phone Number"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func showLoadingHUD() {
        progressHUD = JGProgressHUD(style: .dark)
        progressHUD?.textLabel.text = "Loading..."
        progressHUD?.show(in: self.view)
    }
    func hideLoadingHUD() {
        progressHUD?.dismiss()
        progressHUD = nil
    }
}
