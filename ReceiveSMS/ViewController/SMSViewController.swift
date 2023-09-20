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
import GoogleMobileAds

class SMSViewController:UIViewController, UITableViewDelegate, UITableViewDataSource,GADBannerViewDelegate{
    var progressHUD: JGProgressHUD?
    
    @IBOutlet weak var smstableView: UITableView!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var numberLabel: UILabel!
    
    var bannerView: GADBannerView!
    var cellDataArray : [CellModel] = []
    var number:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        smstableView.delegate = self
        smstableView.dataSource = self
        self.view.overrideUserInterfaceStyle = .light
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        self.view.addGestureRecognizer(panGesture)
        
        smstableView.separatorStyle = .none
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        textField.layer.cornerRadius = 25
        numberLabel.text = number
        let backButtonImage = UIImage(named: "backarrow")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        backButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        let settingButtonImage = UIImage(named: "settingiconMain")?.withRenderingMode(.alwaysOriginal)
        let settingButton = UIBarButtonItem(image: settingButtonImage, style: .plain, target: self, action: #selector(settingButtonTapped))
        navigationItem.rightBarButtonItem = settingButton
        settingButton.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        let nib = UINib(nibName: "SMSCell", bundle: nil)
        smstableView.register(nib, forCellReuseIdentifier: SMSCell.identifier)
        DispatchQueue.main.async {
            self.showLoadingHUD()
        }
        fetchDataForNumber()
        DispatchQueue.main.async {
            self.hideLoadingHUD()
        }
        loadAd()
    }
    
    func loadAd(){
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
    
    func fetchDataForNumber() {
        let urlString = "https://receive-smss.com/sms/\(number)/"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let data = data {
                    do {
                        let html = String(data: data, encoding: .utf8)
                        let doc = try SwiftSoup.parse(html ?? "")
                        
                        let messageDetails = try doc.select("div.row.message_details")
                        var newDataArray: [CellModel] = []
                        
                        for messageDetail in messageDetails {
                            let senderElement = try messageDetail.select("div.col-md-3.sender").first()
                            let contentElement = try messageDetail.select("div.col-md-6.msg").first()
                            let timeElement = try messageDetail.select("div.col-md-3.time").first()
                            
                            let sender = try senderElement?.text() ?? ""
                            let content = try contentElement?.text() ?? ""
                            let time = try timeElement?.text() ?? ""
                            
                            let cellData = CellModel(sender: sender, content: content, time: time)
                            newDataArray.append(cellData)
                        }
                        
                        DispatchQueue.main.async {
                            self.cellDataArray = newDataArray
                            self.smstableView.reloadData()
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
    @objc func settingButtonTapped(){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "settingviewcontroller") as? SettingViewController {
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.title = "Setting"
            navigationController?.pushViewController(vc, animated: true)
        }
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
        return 185
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
