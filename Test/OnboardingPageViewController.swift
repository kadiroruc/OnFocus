//
//  OnboardingPageViewController.swift
//  Test
//
//  Created by Abdulkadir Oruç on 23.03.2025.
//

import UIKit

class OnboardingContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    var pageViewController: UIPageViewController!
    
    var pages = [UIViewController]()
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPages()
        setupPageViewController()
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = currentIndex
        
        pageControl.currentPageIndicatorTintColor = .gray
        pageControl.pageIndicatorTintColor = .systemGray5
        
    }
    
    func setupPages() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        pages.append(storyboard.instantiateViewController(withIdentifier: "Page1"))
        pages.append(storyboard.instantiateViewController(withIdentifier: "Page2"))
        pages.append(storyboard.instantiateViewController(withIdentifier: "Page3"))
    }
    
    func setupPageViewController() {
        for child in children {
            if let pvc = child as? UIPageViewController {
                pageViewController = pvc
                
                // Başlangıç sayfasını göster
                pageViewController.setViewControllers([pages[currentIndex]], direction: .forward, animated: true, completion: nil)
                
                // Elle kaydırmayı aktif etmek için dataSource ve delegate ekle
                pageViewController.dataSource = self
                pageViewController.delegate = self
            }
        }
    }

    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if currentIndex == pages.count - 1 {
                // Son sayfadaysak, geçiş yapıyoruz
                performSegue(withIdentifier: "goToLogin", sender: nil)
                
            } else {
                // Sonraki sayfaya geçiyoruz
                let nextIndex = currentIndex + 1
                
                pageViewController.setViewControllers([pages[nextIndex]], direction: .forward, animated: true, completion: nil)
                
                currentIndex = nextIndex
                pageControl.currentPage = currentIndex
                
                // Son sayfadaysak buton textini "Get Started" yap
                if currentIndex == pages.count - 1 {
                    nextButton.setTitle("Get Started", for: .normal)
                }
            }
    }
    
    // Önceki sayfayı döndürür
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = currentIndex - 1
        return previousIndex >= 0 ? pages[previousIndex] : nil
    }

    // Sonraki sayfayı döndürür
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = currentIndex + 1
        return nextIndex < pages.count ? pages[nextIndex] : nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: visibleViewController) {
            
            currentIndex = index
            pageControl.currentPage = currentIndex
            
            // Son sayfa mı? Buton textini güncelle
            if currentIndex == pages.count - 1 {
                nextButton.setTitle("Get Started", for: .normal)
            } else {
                nextButton.setTitle("Next", for: .normal)
            }
        }
    }


}
