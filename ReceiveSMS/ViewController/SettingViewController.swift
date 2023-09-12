//
//  SettingViewController.swift
//  ReceiveSMS
//
//  Created by Trung on 31/08/2023.
//

import UIKit
import Toast
import StoreKit

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
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        self.view.addGestureRecognizer(panGesture)
        
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
        let selectedItem = settingitem[indexPath.row]
        if (selectedItem == "Feedback") {
            showToast(message: "Coming soon...")
        }
        else if (selectedItem == "Rate us"){
            showAppStoreRating()
        }
        else if (selectedItem == "Share this app"){
            let link = "https://github.com/trungnt1000vn/ReceiveSMS"
            

            let items = [URL(string: link)!]
            

            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            present(activityViewController, animated: true, completion: nil)
        }
        
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
    func showAppStoreRating() {
        if #available(iOS 14.0, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Handle older iOS versions where SKStoreReviewController is not available.
            // You can navigate the user to the App Store page using a regular link or prompt them to rate the app in a different way.
        }
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
}
