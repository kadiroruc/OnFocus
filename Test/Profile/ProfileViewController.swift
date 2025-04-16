//
//  ProfileViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 11.04.2025.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var streakView: UIView!
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var averageWorkTimeLabel: UILabel!
    @IBOutlet var streakDayLabel: UILabel!
    @IBOutlet var leftTimeButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var rightTimeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupCollectionView()
    }
    
    func setupView(){
        averageWorkTimeLabel.layer.cornerRadius = 15
        averageWorkTimeLabel.clipsToBounds = true
        
        streakDayLabel.layer.cornerRadius = 15
        streakDayLabel.clipsToBounds = true
    }

    func setupCollectionView(){
        streakView.backgroundColor = .systemGray6
        streakView.layer.cornerRadius = 20
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: "DayCell")
    }
    
    @IBAction func leftTimeButtonTapped(_ sender: Any) {
    }
    
    @IBAction func rightTimeButtonTapped(_ sender: Any) {
    }
    @IBAction func addFriendBarButtonTapped(_ sender: Any) {
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCell
                cell.configure(isActive: true, isStreak: indexPath.item % 5 == 0) // örnek yapılandırma
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 22, height: 22)
    }
    
}
