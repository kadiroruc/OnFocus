//
//  SettingsViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import UIKit

protocol SettingsViewInterface: AnyObject{
    
}

class SettingsViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    private lazy var viewModel = SettingsViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        setupCollectionView()

    }
    
    func setupCollectionView(){

        collectionView.delegate = self
        collectionView.dataSource = self
        
//        let layout = UICollectionViewFlowLayout()
//        
//        // itemSize'ı buradan ayarlıyoruz
//        layout.itemSize = CGSize(width: self.view.frame.width * 0.9, height: 50)
//        
//        // collectionView'e layout'u atama
//        collectionView.collectionViewLayout = layout
        
        //collectionView.register(SettingsCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

}

extension SettingsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SettingsCollectionViewCell
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 8
        cell.imageView.backgroundColor = .systemBlue
        cell.imageView.tintColor = .white
        cell.imageView.layer.cornerRadius = 4
        cell.imageView.contentMode = .scaleAspectFit
        
        viewModel.configureCell(cell: cell, at: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width * 0.9, height: 50)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    
}
