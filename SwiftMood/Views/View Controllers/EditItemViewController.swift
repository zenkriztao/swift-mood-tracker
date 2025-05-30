//
//  EditItemViewController.swift
//  SwiftMood
//
//  Created by zenkriztao  on 1/23/23.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import Charts

class EditItemViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	var item: MoodsItem? = nil
	var moods: [Mood] = []
	var bEditing = false
	
	let scrollView: UIScrollView = {
		let sv = UIScrollView()
		sv.backgroundColor = UIColor(named: "bg-color")
		sv.translatesAutoresizingMaskIntoConstraints = false
		return sv
	}()
	
	let dateLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 32, weight: .bold)
		label.textColor = UIColor(named: "label")
		label.translatesAutoresizingMaskIntoConstraints = false;
		return label
	}()
	
	let timeLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 22)
		label.textColor = UIColor(named: "info")
		label.translatesAutoresizingMaskIntoConstraints = false;
		return label
	}()
	
	var moodCounters: [Double] = []
	
	var chartView: PieChartView!
	let chartTapper = UITapGestureRecognizer(target: self, action: #selector(chartPressed))
	
	let deleteButton: UIButton = {
		let button = UIButton()
		let largeConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large)
		button.setImage(UIImage(systemName: "trash", withConfiguration: largeConfig), for: .normal)
		button.tintColor = .white
		button.backgroundColor = UIColor(named: "cancel")
		button.layer.cornerRadius = 24
		button.isHidden = true
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	let legendButton: UIButton = {
		let button = UIButton()
		button.setTitle("Show Legend", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
		button.titleLabel?.textColor = UIColor(named: "panel-color")
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	
	let moodsView: UICollectionView = {
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.scrollDirection = .horizontal
		flowLayout.itemSize = CGSize(width: 110, height: 30)
		flowLayout.minimumLineSpacing = 5.0
		flowLayout.minimumInteritemSpacing = 2
		let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
		cv.backgroundColor = .clear
		cv.showsHorizontalScrollIndicator = false
		cv.translatesAutoresizingMaskIntoConstraints = false
		return cv
	}()
	
	let addMoodsButton: UIButton = {
		let button = UIButton()
		let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular, scale: .large)
		button.setImage(UIImage(systemName: "plus", withConfiguration: largeConfig), for: .normal)
		button.imageView?.tintColor = .white
		button.layer.cornerRadius = 25
		button.backgroundColor = UIColor(named: "AccentColor")
		button.isHidden = true
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	let detailsTF: UITextView = {
		let tv = UITextView()
		tv.isEditable = true
		tv.textColor = UIColor(named: "info")
		tv.font = .systemFont(ofSize: 14)
		tv.backgroundColor = UIColor(named: "panel-color")
		tv.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
		tv.isEditable = false
		tv.layer.borderWidth = 0
		tv.layer.cornerRadius = 15
		tv.translatesAutoresizingMaskIntoConstraints = false
		return tv
	}()
	
	let topButton: UIButton = {
		let button = UIButton()
		let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular, scale: .large)
		button.setImage(UIImage(systemName: "pencil", withConfiguration: largeConfig), for: .normal)
		button.imageView?.tintColor = .white
		button.layer.cornerRadius = 32
		button.backgroundColor = UIColor.gray
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	let bottomButton: UIButton = {
		let button = UIButton()
		let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular, scale: .large)
		button.setImage(UIImage(systemName: "checkmark", withConfiguration: largeConfig), for: .normal)
		button.imageView?.tintColor = .white
		button.layer.cornerRadius = 32
		button.backgroundColor = UIColor(named: "AccentColor")
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
		
	}()
	
	override func viewWillAppear(_ animated: Bool) {
		moodsView.reloadData()
		initMoodCounters()
		getAllMoods()
		customizeChart(dataPoints: MoodsManager.categories, values: moodCounters)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(named: "bg-color")
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		let tapGR = UITapGestureRecognizer(target: self, action: #selector(screenPressed))
		scrollView.addGestureRecognizer(tapGR)
		scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
		
		deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
		addMoodsButton.addTarget(self, action: #selector(addMoodsTapped), for: .touchUpInside)
		topButton.addTarget(self, action: #selector(topPressed), for: .touchUpInside)
		bottomButton.addTarget(self, action: #selector(bottomPressed), for: .touchUpInside)
		
		if let item = item {
			dateLabel.text = item.timestamp.formatted(date: .abbreviated, time: .omitted)
			timeLabel.text = item.timestamp.formatted(date: .omitted, time: .shortened)
			detailsTF.text = item.details
		}
		
		
		moods = item!.moods
		
		moodsView.register(HomeMoodCell.self, forCellWithReuseIdentifier: "nonedit-mood")
		
		moodsView.register(EditMoodCell.self, forCellWithReuseIdentifier: "edit-mood")
		
		moodsView.dataSource = self
		moodsView.delegate = self
		
		chartView = PieChartView(frame: CGRect(x: view.frame.width - 200, y: 0 ,width: 200 ,height: 200))
		
		view.addSubview(scrollView)
		scrollView.addSubview(dateLabel)
		scrollView.addSubview(timeLabel)
		scrollView.addSubview(chartView)
		scrollView.addSubview(deleteButton)
		scrollView.addSubview(moodsView)
		scrollView.addSubview(addMoodsButton)
		scrollView.addSubview(detailsTF)
		scrollView.addSubview(topButton)
		scrollView.addSubview(bottomButton)
		
		setupSubviews()
	}
	
	// Add spaces at the beginning and the end of the collection view
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		
		if bEditing {
			return UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 75)
		} else {
			return UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
		}
	}
	
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if item != nil {
			return moods.count
		}
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if(bEditing){
			
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "edit-mood", for: indexPath) as? EditMoodCell {
				
				switch moods[indexPath.item].section {
				case "Sad":
					cell.backgroundColor = UIColor(named: "mood-sad")
				case "Fearful":
					cell.backgroundColor = UIColor(named: "mood-fearful")
				case "Disgusted":
					cell.backgroundColor = UIColor(named: "mood-disgusted")
				case "Angry":
					cell.backgroundColor = UIColor(named: "mood-angry")
				case "Happy":
					cell.backgroundColor = UIColor(named: "mood-happy")
				case "Surprised":
					cell.backgroundColor = UIColor(named: "mood-surprised")
				default:
					cell.backgroundColor = .gray
				}
				
				cell.parent = self
				cell.mood = self.moods[indexPath.item]
				cell.moodLabel.text = cell.mood.name
				
				return cell
			}
		} else {
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nonedit-mood", for: indexPath) as? HomeMoodCell {
				
				switch moods[indexPath.item].section {
				case "Sad":
					cell.backgroundColor = UIColor(named: "mood-sad")
				case "Fearful":
					cell.backgroundColor = UIColor(named: "mood-fearful")
				case "Disgusted":
					cell.backgroundColor = UIColor(named: "mood-disgusted")
				case "Angry":
					cell.backgroundColor = UIColor(named: "mood-angry")
				case "Happy":
					cell.backgroundColor = UIColor(named: "mood-happy")
				case "Surprised":
					cell.backgroundColor = UIColor(named: "mood-surprised")
				default:
					cell.backgroundColor = .gray
				}
				
				cell.moodLabel.text = self.moods[indexPath.item].name
				return cell
			}
		}
		return UICollectionViewCell()
	}
	
	
	func setupSubviews(){
		
		
		scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		
		scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		scrollView.contentLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		scrollView.contentLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		
		dateLabel.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 15).isActive = true
		dateLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 15).isActive = true
		
		timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 15).isActive = true
		timeLabel.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 15).isActive = true
		
		deleteButton.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -15).isActive = true
		deleteButton.topAnchor.constraint(equalTo: dateLabel.topAnchor).isActive = true
		deleteButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
		deleteButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
		
		moodsView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 100).isActive = true
		moodsView.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor).isActive = true
		moodsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
		moodsView.heightAnchor.constraint(equalToConstant: 105).isActive = true
		
		addMoodsButton.rightAnchor.constraint(equalTo: moodsView.rightAnchor, constant: -15).isActive = true
		addMoodsButton.centerYAnchor.constraint(equalTo: moodsView.centerYAnchor).isActive = true
		addMoodsButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
		addMoodsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		detailsTF.topAnchor.constraint(equalTo: moodsView.bottomAnchor, constant: 15).isActive = true
		detailsTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		detailsTF.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9).isActive = true
		detailsTF.heightAnchor.constraint(equalToConstant: 250).isActive = true
		
		topButton.topAnchor.constraint(equalTo: detailsTF.bottomAnchor, constant: 30).isActive = true
		topButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.frame.width / 6).isActive = true
		topButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
		topButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
		
		bottomButton.topAnchor.constraint(equalTo: topButton.topAnchor).isActive = true
		bottomButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.frame.width / 6).isActive = true
		bottomButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
		bottomButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
		
	}
	
	func initMoodCounters(){
		for _ in 0...MoodsManager.categories.count {
			moodCounters.append(0)
		}
	}
	
	func getAllMoods(){
		
		if let item = item {
			for mood in item.moods {
				switch mood.section {
				case MoodsManager.categories[0]:
					moodCounters[0] += 1
				case MoodsManager.categories[1]:
					moodCounters[1] += 1
				case MoodsManager.categories[2]:
					moodCounters[2] += 1
				case MoodsManager.categories[3]:
					moodCounters[3] += 1
				case MoodsManager.categories[4]:
					moodCounters[4] += 1
				case MoodsManager.categories[5]:
					moodCounters[5] += 1
				default:
					break
				}
			}
		}
		
	}
	
	func customizeChart(dataPoints: [String], values: [Double]) {
		chartView.legend.enabled = false
		chartView.animate(xAxisDuration: 1, yAxisDuration: 1, easingOption: .easeOutCirc)
		chartView.drawHoleEnabled = false
		chartView.drawEntryLabelsEnabled = true
		chartView.entryLabelFont = .boldSystemFont(ofSize: 14)
		chartView.entryLabelColor = UIColor(named: "label")
		
		var dataEntries: [ChartDataEntry] = []
		for i in 0..<dataPoints.count {
			let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
			dataEntries.append(dataEntry)
		}
		let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: dataPoints[0])
		pieChartDataSet.colors = ChartManager.colorsOfCharts(numbersOfColor: dataPoints.count)
		pieChartDataSet.drawValuesEnabled = false
		let pieChartData = PieChartData(dataSet: pieChartDataSet)
		let format = NumberFormatter()
		format.numberStyle = .decimal
		format.maximumFractionDigits = 0
		let formatter = DefaultValueFormatter(formatter: format)
		pieChartData.setValueFormatter(formatter)
		chartView.data = pieChartData
	}
	
	func deleteMood(mood: Mood){
		var updatedMoods = moods
		let deleteIndex = updatedMoods.firstIndex(where: {$0.name == mood.name })
		updatedMoods.remove(at: deleteIndex! as Int)
		moods = updatedMoods
		moodsView.reloadData()
	}
	
	func isSame() -> Bool {
		if let item = item{
			
			if detailsTF.text! != item.details {
				return false
			}
			
			if moods.count != item.moods.count {
				return false
			}
			
			for i in 0..<item.moods.count {
				if item.moods[i].name != moods[i].name {
					return false
				}
			}
		}
		
		return true
	}
	
	func startEditing() {
		bEditing = true
		addMoodsButton.isHidden = false
		
		let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular, scale: .large)
		
		topButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: largeConfig), for: .normal)
		
		moodsView.reloadData()
		
		detailsTF.isEditable = true
		
		chartView.isHidden = true
		deleteButton.isHidden = false
	}
	
	func stopEditing() {
		bEditing = false
		addMoodsButton.isHidden = true
		topButton.setTitleColor(.white, for: .normal)
		
		let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular, scale: .large)
		
		topButton.setImage(UIImage(systemName: "pencil", withConfiguration: largeConfig), for: .normal)
		
		if let item = item {
			detailsTF.text = item.details
			moods = item.moods
		}
		
		detailsTF.isEditable = false
		
		moodsView.reloadData()
		
		chartView.isHidden = false
		deleteButton.isHidden = true
	}
	
	func save(){
		
		if let user = Auth.auth().currentUser, let item = item {
			
			let preparedMoods = MoodsManager().prepareMoodsForFirebase(moods: moods)
			
			Firestore.firestore().collection("users").document(user.uid).collection("items").document(item.id).updateData([
				
				"moods": preparedMoods,
				"details": detailsTF.text!
				
			], completion: { error in
				
				self.navigationController?.popViewController(animated: true)
			})
			
			
		}
	}
	
	func cancel(){
		
		if !isSame() {
			let alert = UIAlertController(title: "Cancel?", message: "Are you sure you want to cancel editing?", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
				alert.dismiss(animated: true)
			}))
			alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
				alert.dismiss(animated: true)
				self.stopEditing()
			}))
			
			self.present(alert, animated: true)
		} else {
			self.stopEditing()
		}
	}
	
	@objc func screenPressed(){
		scrollView.endEditing(true)
	}
	
	@objc func deleteTapped(){
		
		let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this post?", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
			if let user = Auth.auth().currentUser, let item = self.item {
				Firestore.firestore().collection("users").document(user.uid).collection("items").document(item.id).delete(){ error in
					alert.dismiss(animated: true)
					if let error = error {
						print(error)
					} else {
						self.navigationController?.popViewController(animated: true)
					}
				}
			}
		}))
		alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
			alert.dismiss(animated: true)
		}))
		self.present(alert, animated: true, completion: nil)
	}
	
	@objc func addMoodsTapped(){
		let emvc = EditMoodsViewController(collectionViewLayout: UICollectionViewFlowLayout())
		emvc.selectedMoods = moods
		emvc.parentVC = self
		self.navigationController?.pushViewController(emvc, animated: true)
	}
	
	@objc func topPressed(){
		if(bEditing){
			cancel()
		} else {
			startEditing()
		}
	}
	
	@objc func bottomPressed(){
		if(bEditing){
			save()
		} else {
			navigationController?.popViewController(animated: true)
		}
	}
	
	@objc func chartPressed() {
		let details = MoodDetailsViewController(values: moodCounters)
		navigationController?.pushViewController(details, animated: true)
	}
	
	@objc func keyboardWillShow(notification: Notification){
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + keyboardSize.height)
		}
	}
	
	@objc func keyboardWillHide(notification: Notification){
		scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
	}
	
	init(item: MoodsItem) {
		self.item = item
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
