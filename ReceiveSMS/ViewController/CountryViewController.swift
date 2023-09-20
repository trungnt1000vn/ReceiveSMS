//
//  CountryViewController.swift
//  ReceiveSMS
//
//  Created by Trung on 22/08/2023.
//

import UIKit
import SwiftSoup
import Toast
import SDWebImage
import GoogleMobileAds

class CountryViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, GADFullScreenContentDelegate, GADBannerViewDelegate {
    var cellDataArray: [CellData] = []
    var originalCellDataArray: [CellData] = []
    private var interstitial: GADInterstitialAd?
    var bannerView: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var BG1: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var textFiled: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var goproButn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAd()
        loadAdBanner()
        searchBar.showsCancelButton = true
        self.view.overrideUserInterfaceStyle = .light
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpRecent()
    }
    
    func loadAd() {
           let request = GADRequest()
           GADInterstitialAd.load(
               withAdUnitID: "ca-app-pub-3940256099942544/4411468910",
               request: request,
               completionHandler: { [self] ad, error in
                   if let error = error {
                       print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                       return
                   }
                   interstitial = ad
                   interstitial?.fullScreenContentDelegate = self
               }
           )
       }

       func showAd() {
           if let interstitial = interstitial {
               let root = UIApplication.shared.keyWindow!.rootViewController
               interstitial.present(fromRootViewController: root!)
           }
       }

       // Được gọi khi quảng cáo đã hoàn thành
       func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
           print("Ad did dismiss full screen content.")
           loadAd() // Tải quảng cáo mới để chuẩn bị cho lần sau
       }

       // Được gọi khi quảng cáo không thể hiển thị
       func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
           print("Ad did fail to present full screen content.")
           self.presentNextViewController() // Chuyển sang màn hình tiếp theo nếu quảng cáo không thể hiển thị
       }

       // Hàm để chuyển sang màn hình tiếp theo
       func presentNextViewController() {
           let nextViewController = CountryViewController() // Thay bằng màn hình tiếp theo của bạn
           self.navigationController?.pushViewController(nextViewController, animated: true)
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
    
    func loadAdBanner(){
        let adSize = GADAdSizeFromCGSize(CGSize(width: view.frame.width, height: 55))
        bannerView = GADBannerView(adSize: adSize)
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.backgroundColor = UIColor.clear
        
        bannerView.layer.borderWidth = 2.0
        bannerView.layer.borderColor = UIColor.clear.cgColor
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
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
    
    
    @IBAction func goProTapped(_ sender: Any) {
        showToast(message: "Coming soon...")
    }
    
    @IBAction func settingTapped(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "settingviewcontroller") as? SettingViewController {
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.title = "Setting"
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
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        fetchData()
        tableView.reloadData()
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
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    showAd()
                }
//        let vc = ReceiveSMS.NumbersViewController.makeSelf()
//        let cellData = cellDataArray[indexPath.row]
//        let countryName = cellData.countryName
//        vc.country = countryName
//        UserDefaults.standard.setValue(countryName, forKey: "countryRecent")
//        UserDefaults.standard.setValue("No number yet", forKey: "numberRecent")
//        DispatchQueue.main.async {
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableCell.identifier, for: indexPath) as! TableCell
        let cellData = cellDataArray[indexPath.row]
        cell.countryLabel.text = cellData.countryName
        /// Import offline
        //cell.iconImage.image = UIImage(named: cellData.countryName.lowercased())
        
        let countryUse = cellData.countryName.lowercased()
        let filename = "\(countryUse).png"
        let path = "countriesphotos/\(filename)"
        DispatchQueue.global().async {
            StorageManager.shared.downloadURL(for: path, completion: { result in
                switch result {
                case .success(let url):
                    cell.iconImage.sd_setImage(with: url, completed: nil)
                case .failure(let error):
                    print("Failed to download the image : \(error)")
                }
            })
        }
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
