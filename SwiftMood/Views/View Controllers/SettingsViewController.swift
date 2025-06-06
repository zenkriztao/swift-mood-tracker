//
//  SettingsViewController.swift
//  SwiftMood
//
//  Created by zenkriztao  on 11/7/22.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
	
	let privacyButton: UIButton = {
		let button = UIButton()
		button.setTitle("Privacy Policy", for: .normal)
		button.backgroundColor = UIColor(named: "panel-color")
		button.layer.cornerRadius = 15
		button.layer.borderWidth = 0
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOffset = CGSize(width: 2, height: 2)
		button.layer.shadowOpacity = 0.3
		button.layer.shadowRadius = 3
		button.setTitleColor(UIColor(named: "label"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	let signOutButton: UIButton = {
		let button = UIButton()
		button.setTitle("Sign Out", for: .normal)
		button.backgroundColor = UIColor(named: "panel-color")
		button.layer.cornerRadius = 15
		button.layer.borderWidth = 0
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOffset = CGSize(width: 2, height: 2)
		button.layer.shadowOpacity = 0.3
		button.layer.shadowRadius = 3
		button.setTitleColor(UIColor(named: "label"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	let deleteAccountButton: UIButton = {
		let button = UIButton()
		button.setTitle("Delete Account", for: .normal)
		button.backgroundColor = UIColor(named: "panel-color")
		button.layer.cornerRadius = 15
		button.layer.borderWidth = 0
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOffset = CGSize(width: 2, height: 2)
		button.layer.shadowOpacity = 0.3
		button.layer.shadowRadius = 3
		button.setTitleColor(UIColor(named: "dangerous"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(named: "bg-color")
		
		privacyButton.addTarget(self, action: #selector(privacyPressed), for: .touchUpInside)
		signOutButton.addTarget(self, action: #selector(signOutPressed), for: .touchUpInside)
		deleteAccountButton.addTarget(self, action: #selector(deleteAccountPressed), for: .touchUpInside)
		
		view.addSubview(privacyButton)
		view.addSubview(signOutButton)
		view.addSubview(deleteAccountButton)
		
		setupSubviews()
	}
	
	func setupSubviews(){
		setupPrivacyButton()
		setupSignoutButton()
		setupDeleteAccountButton()
	}
	
	func setupPrivacyButton(){
		
		privacyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 75).isActive = true
		privacyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		privacyButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
		privacyButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	func setupSignoutButton(){
		signOutButton.topAnchor.constraint(equalTo: privacyButton.bottomAnchor, constant: 50).isActive = true
		signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		signOutButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
		signOutButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	func setupDeleteAccountButton(){
		deleteAccountButton.topAnchor.constraint(equalTo: signOutButton.bottomAnchor, constant: 10).isActive = true
		deleteAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		deleteAccountButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
		deleteAccountButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	
	@objc func privacyPressed(){
		if let url = URL(string: "https://alexwayne.org/apps/mood-tracker/privacypolicy.html") {
			if #available(iOS 10.0, *) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			} else {
				UIApplication.shared.openURL(url)
			}
		}
	}
	
	@objc func signOutPressed(){
		AuthManager().logout()
	}
	
	@objc func deleteAccountPressed(){
		self.navigationController?.pushViewController(DeleteAccountViewController(), animated: true)
	}
}
