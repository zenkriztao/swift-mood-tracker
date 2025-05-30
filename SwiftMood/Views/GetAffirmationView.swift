//
//  GetAffirmationView.swift
//  SwiftMood
//
//  Created by zenkriztao  on 11/10/22.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class AffirmationsViewController: UIViewController {
	
	var quote: Quote?
	var lastAff: Quote?
	var gettingAff = false
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 28)
		label.text = "Words of Wisdom"
		label.textColor = UIColor(named: "label")
		label.numberOfLines = 0
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14)
		label.text = "Tap below to see some famous words of wisdom"
		label.textAlignment = .center
		label.textColor = UIColor(named: "info")
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let indicatorContainer: UIView = {
		let v = UIView()
		v.backgroundColor = .white
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()
	
	let activityIndicator: UIActivityIndicatorView = {
		let ai = UIActivityIndicatorView(style: .large)
		ai.style = .large
		ai.color = UIColor(named: "info")
		ai.hidesWhenStopped = true
		ai.translatesAutoresizingMaskIntoConstraints = false
		return ai
	}()
	
	let quoteLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 18)
		label.textColor = UIColor(named: "label")
		label.numberOfLines = 0
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let authorLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .semibold)
		label.textColor = UIColor(named: "label")
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let getButton: UIButton = {
		let button = UIButton()
		button.setTitle("Get Quote", for: .normal)
		button.setTitleColor(UIColor(named: "label"), for: .normal)
		button.backgroundColor = UIColor(named: "panel-color")
		button.layer.borderColor = UIColor.clear.cgColor
		button.layer.borderWidth = 1
		button.layer.cornerRadius = 15
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOffset = CGSize(width: 2, height: 2)
		button.layer.shadowOpacity = 0.3
		button.layer.shadowRadius = 4
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	let undoButton: UIButton = {
		let button = UIButton()
		button.setTitle("Go back", for: .normal)
		button.setTitleColor(UIColor(named: "info"), for: .normal)
		button.isHidden = true
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(named: "bg-color")
		
		getButton.addTarget(self, action: #selector(getButtonPressed), for: .touchUpInside)
		undoButton.addTarget(self, action: #selector(undoPressed), for: .touchUpInside)
		
		view.addSubview(titleLabel)
		view.addSubview(descriptionLabel)
		view.addSubview(quoteLabel)
		view.addSubview(authorLabel)
		view.addSubview(activityIndicator)
		view.addSubview(getButton)
		view.addSubview(undoButton)
		setupSubviews()
	}
	
	func setupSubviews(){
		titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
		titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
		titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
		
		descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25).isActive = true
		descriptionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
		descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		
		quoteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		quoteLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		quoteLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
		
		authorLabel.rightAnchor.constraint(equalTo: quoteLabel.rightAnchor).isActive = true
		authorLabel.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 25).isActive = true
		
		
		getButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		getButton.bottomAnchor.constraint(equalTo: undoButton.topAnchor, constant: -15).isActive = true
		getButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
		getButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
		
		undoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		undoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25).isActive = true
		undoButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
		
		activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		activityIndicator.bottomAnchor.constraint(equalTo: getButton.topAnchor, constant: -50).isActive = true
	}
	
	@objc func getButtonPressed(){
		if(!gettingAff){
			gettingAff = true
			getAffirmation()
			self.activityIndicator.startAnimating()
		}
	}
	
	@objc func undoPressed(){
		if lastAff != nil {
			quote = lastAff
			
			quoteLabel.text = quote?.q
			authorLabel.text = "- \(quote?.a ?? "Unknown")"
		}
		undoButton.isHidden = true
	}
	
	func getAffirmation() {
		if let url = URL(string: "https://zenquotes.io/api/random") {
			let session = URLSession(configuration: .default)
			let task = session.dataTask(with: url) { data, response, error in
				if let error = error {
					print(error)
					return
				}
				if let data = data {
					self.parseJSON(data)
					
				}
				Firestore.firestore().collection("analytics").document("affirmations").updateData(["sent": FieldValue.increment(Int64(1))])
				if let user = Auth.auth().currentUser{
					Firestore.firestore().collection("users").document(user.uid).updateData(["quotesRequested": FieldValue.increment(Int64(1))])
				}
			}
			task.resume()
		}
	}
	
	func parseJSON(_ data: Data) {
		let decoder = JSONDecoder()
		do {
			let decodedData = try decoder.decode([Quote].self, from: data)
			DispatchQueue.main.async {
				
				self.lastAff = self.quote
				self.quote = decodedData[0]
				
				if self.quote?.a == "zenquotes.io" {
					self.quoteLabel.text = "Too many requests. Please wait a moment before trying again"
					self.authorLabel.text = ""
				} else {
					self.quoteLabel.text = self.quote?.q
					self.authorLabel.text = "- \(self.quote?.a ?? "Unknown")"
				}
				
				if self.lastAff != nil {
					
					if self.lastAff?.a == "zenquotes.io" {
						self.undoButton.isHidden = true
					} else {
						self.undoButton.isHidden = false
					}
				}
				self.gettingAff = false
				self.activityIndicator.stopAnimating()
			}
		} catch {
			print(error)
		}
	}
	
}
