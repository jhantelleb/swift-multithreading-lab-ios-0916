//
//  ImageViewControllerExtensions.swift
//  swift-multithreading-lab
//
//  Created by Ian Rahman on 10/31/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit


// MARK: Views

extension ImageViewController {
    
    func setUpViews() {
        
        scrollView = UIScrollView(frame: view.frame)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        
        setUpScrollView()
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = UIColor.cyan
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    func setUpScrollView() {
        
        if let image = imageView.image {
            scrollView.contentOffset = CGPoint(x: image.size.width/2, y: image.size.height/2)
        } else {
            guard let bull = UIImage(named: "bull") else { return }
            flatigram.image = bull
            imageView = UIImageView(image: bull)
            scrollView.contentOffset = CGPoint(x: bull.size.width/2, y: bull.size.height/2)
        }
        
        scrollView.contentSize = imageView.bounds.size
        setZoomScale()
    }
    
    func presentFilteredAlert() {
        let alert = UIAlertController(title: "Uh oh!", message: "Image was already filtered", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        print("Image is already filtered")
    }
    
    func filterImage(with completion: @escaping (Bool) -> Void ) {
        let queue = OperationQueue()
        queue.name = "Image Filtration Queue"
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        for filter in filtersToApply {
            let filterQueue = FilterOperation(flatigram: flatigram, filter: filter)
            filterQueue.completionBlock = {
                if queue.operationCount == 0 {
                    DispatchQueue.main.async(execute: {
                    self.flatigram.state = .filtered
                    completion(true)
                    })
                }
            }
            queue.addOperation( filterQueue )
            print("Added FilterOperation with \(filter) to \(queue.name!)")
        }
    }
    
    func startProcess() {
        self.filterButton.isEnabled = false
        self.chooseImageButton.isEnabled = false
        activityIndicator.startAnimating()
        filterImage { (success) in
            OperationQueue.main.addOperation {
                if success {
                    print("Would you look at that beautiful photo!")
                    self.filterButton.isEnabled = true
                    self.chooseImageButton.isEnabled = true
                    self.imageView.image = self.flatigram.image
                    self.activityIndicator.stopAnimating()
                } else {
                    print("Photo did not filter. :(")
                }
            }
        }
    }
    
}


// MARK: Scroll View Delegate

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func setZoomScale() {
        
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 1.0
    }
    
}


// MARK: Image Picker Delegate

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        flatigram.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        flatigram.state = .unfiltered
        imageView.image = flatigram.image
        imageView.contentMode = .scaleAspectFit
        self.setUpScrollView()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func selectImage() {
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
}








