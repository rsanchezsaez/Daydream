//
//  SampleViewController.swift
//  DaydreamSample
//
//  Created by Sachin on 2/2/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

import UIKit

// Convenience extension for drawing circular shape layers
private extension CAShapeLayer {
	convenience init(circleWithSize size: CGSize) {
		self.init()
		self.path = UIBezierPath(ovalIn: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)).cgPath
	}
}

// Convenience extension with a custom app tint color
private extension UIColor {
	static let appTint = UIColor(colorLiteralRed: 80 / 255, green: 227 / 255, blue: 194 / 255, alpha: 1)
}

class SampleViewController: UIViewController {
	// Image views for the controller and volume buttons
	fileprivate let controllerImageView: UIImageView
	fileprivate let volumeUpImageView: UIImageView
	fileprivate let volumeDownImageView: UIImageView
	
	// Image view + constraints for showing the current touchpad point
	fileprivate let touchpadPointImageView: UIImageView
	fileprivate var touchpadPointLeftConstraint: NSLayoutConstraint?
	fileprivate var touchpadPointTopConstraint: NSLayoutConstraint?
	
	// Overlays to show selection state
	fileprivate let touchpadButtonOverlay: CAShapeLayer
	fileprivate let appButtonOverlay: CAShapeLayer
	fileprivate let homeButtonOverlay: CAShapeLayer
	fileprivate let volumeUpButtonOverlay: CAShapeLayer
	fileprivate let volumeDownButtonOverlay: CAShapeLayer
	
	// Keep track of the last point on the touchpad so that we can animate it correctly
	fileprivate var lastPoint = CGPoint.zero
	
	// Layout constants
	fileprivate let controllerSizeMultiplier: CGFloat = 0.4
	fileprivate let controllerHeightToWidthRatio: CGFloat = 3.0
	fileprivate let buttonToControllerRatio: CGFloat = 0.35
	fileprivate let volumeButtonToControllerRatio: CGFloat = 0.025
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		controllerImageView = UIImageView(image: #imageLiteral(resourceName: "Controller"))
		controllerImageView.contentMode = .scaleAspectFit
		
		volumeUpImageView = UIImageView(image: #imageLiteral(resourceName: "Volume Up"))
		volumeDownImageView = UIImageView(image: #imageLiteral(resourceName: "Volume Down"))
		
		touchpadPointImageView = UIImageView(image: #imageLiteral(resourceName: "Finger"))
		touchpadPointImageView.isHidden = true
		
		// Calculate button sizes
		let screenWidth = UIScreen.main.bounds.width
		let controllerWidth = screenWidth * controllerSizeMultiplier
		let buttonWidth = controllerWidth * buttonToControllerRatio
		let volumeButtonWidth = controllerWidth * volumeButtonToControllerRatio
		
		// Create all button overlays with the correct sizes
		touchpadButtonOverlay = CAShapeLayer(circleWithSize: CGSize(width: controllerWidth * 0.9, height: controllerWidth * 0.9))
		appButtonOverlay = CAShapeLayer(circleWithSize: CGSize(width: buttonWidth, height: buttonWidth))
		homeButtonOverlay = CAShapeLayer(circleWithSize: CGSize(width: buttonWidth, height: buttonWidth))
		volumeUpButtonOverlay = CAShapeLayer(circleWithSize: CGSize(width: volumeButtonWidth, height: volumeButtonWidth))
		volumeDownButtonOverlay = CAShapeLayer(circleWithSize: CGSize(width: volumeButtonWidth, height: volumeButtonWidth))
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		view.backgroundColor = UIColor.white
		setupOverlays()
		setupConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureNotifications()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// Position the button overlays correctly
		touchpadButtonOverlay.position = CGPoint(x: controllerImageView.bounds.width / 2, y: (controllerImageView.bounds.width / 2) - 3)
		appButtonOverlay.position = CGPoint(x: controllerImageView.bounds.width / 2, y: (controllerImageView.bounds.height * 0.42))
		homeButtonOverlay.position = CGPoint(x: controllerImageView.bounds.width / 2, y: (controllerImageView.bounds.height * 0.58))
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	func configureNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(SampleViewController.controllerDidConnect(_:)), name: NSNotification.Name.DDControllerDidConnect, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(SampleViewController.controllerDidDisconnect(_:)), name: NSNotification.Name.DDControllerDidDisconnect, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(SampleViewController.controllerDidUpdateBatteryLevel(_:)), name: NSNotification.Name.DDControllerDidUpdateBatteryLevel, object: nil)
	}
	
	func showPress(layer: CAShapeLayer, pressed: Bool) {
		// Set the layer hidden based on the press state.
		// Disable and then re-enable CATransaction actions to avoid animating the layer.
		CATransaction.setDisableActions(true)
		layer.isHidden = !pressed
		CATransaction.setDisableActions(false)
	}
}

// MARK: - View Layout
extension SampleViewController {
	func setupOverlays() {
		let highlightColor = UIColor.appTint.withAlphaComponent(0.6)
		touchpadButtonOverlay.fillColor = highlightColor.cgColor
		appButtonOverlay.fillColor = highlightColor.cgColor
		homeButtonOverlay.fillColor = highlightColor.cgColor
		volumeUpButtonOverlay.fillColor = highlightColor.cgColor
		volumeDownButtonOverlay.fillColor = highlightColor.cgColor
	}
	
	func setupConstraints() {
		view.addSubview(volumeUpImageView)
		view.addSubview(volumeDownImageView)
		view.addSubview(controllerImageView)
		view.addSubview(touchpadPointImageView)
		
		let screenWidth = UIScreen.main.bounds.width
		let controllerWidth = screenWidth * controllerSizeMultiplier
		controllerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		controllerImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		controllerImageView.widthAnchor.constraint(equalToConstant: controllerWidth).isActive = true
		controllerImageView.heightAnchor.constraint(equalTo: controllerImageView.widthAnchor, multiplier: controllerHeightToWidthRatio).isActive = true
		controllerImageView.translatesAutoresizingMaskIntoConstraints = false
		
		volumeUpImageView.centerXAnchor.constraint(equalTo: controllerImageView.rightAnchor).isActive = true
		volumeUpImageView.topAnchor.constraint(equalTo: controllerImageView.topAnchor, constant: 100).isActive = true
		volumeUpImageView.widthAnchor.constraint(equalToConstant: 7).isActive = true
		volumeUpImageView.heightAnchor.constraint(equalToConstant: 29).isActive = true
		volumeUpImageView.translatesAutoresizingMaskIntoConstraints = false
		
		volumeDownImageView.centerXAnchor.constraint(equalTo: volumeUpImageView.centerXAnchor).isActive = true
		volumeDownImageView.topAnchor.constraint(equalTo: volumeUpImageView.bottomAnchor, constant: 4).isActive = true
		volumeDownImageView.widthAnchor.constraint(equalToConstant: 7).isActive = true
		volumeDownImageView.heightAnchor.constraint(equalToConstant: 29).isActive = true
		volumeDownImageView.translatesAutoresizingMaskIntoConstraints = false
		
		touchpadPointLeftConstraint = touchpadPointImageView.centerXAnchor.constraint(equalTo: controllerImageView.leftAnchor, constant: 0)
		touchpadPointTopConstraint = touchpadPointImageView.centerYAnchor.constraint(equalTo: controllerImageView.topAnchor, constant: 0)
		touchpadPointImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
		touchpadPointImageView.heightAnchor.constraint(equalTo: touchpadPointImageView.widthAnchor).isActive = true
		touchpadPointImageView.translatesAutoresizingMaskIntoConstraints = false
		touchpadPointLeftConstraint?.isActive = true
		touchpadPointTopConstraint?.isActive = true
		
		touchpadButtonOverlay.isHidden = true
		appButtonOverlay.isHidden = true
		homeButtonOverlay.isHidden = true
		controllerImageView.layer.addSublayer(touchpadButtonOverlay)
		controllerImageView.layer.addSublayer(appButtonOverlay)
		controllerImageView.layer.addSublayer(homeButtonOverlay)
	}
}

// MARK: - DDController Notifications
extension SampleViewController {
	func controllerDidConnect(_ notification: Notification) {
		guard let controller = notification.object as? DDController else { return }
		
		let touchpadMaxPoint: CGFloat = 250.0
		controller.touchpad.pointChangedHandler = { (touchpad: DDControllerTouchpad, point: CGPoint) in
			let wasHidden = self.touchpadPointImageView.isHidden
			let shouldBeHidden = point.equalTo(CGPoint.zero)
			
			if !shouldBeHidden {
				self.touchpadPointLeftConstraint?.constant = (point.x / touchpadMaxPoint) * self.controllerImageView.bounds.width
				self.touchpadPointTopConstraint?.constant = (point.y / touchpadMaxPoint) * self.controllerImageView.bounds.width
			}
			
			if wasHidden != shouldBeHidden && !self.lastPoint.equalTo(CGPoint.zero) {
				// Animate hiding and showing the indicator
				let initialScale: CGFloat = wasHidden ? 1.15 : 1
				self.touchpadPointImageView.isHidden = false
				self.touchpadPointImageView.transform = CGAffineTransform(scaleX: initialScale, y: initialScale)
				
				UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
					let newScale: CGFloat = shouldBeHidden ? 1.15 : 1.0
					self.touchpadPointImageView.transform = CGAffineTransform(scaleX: newScale, y: newScale)
					self.touchpadPointImageView.alpha = shouldBeHidden ? 0.0 : 1.0
					
				}, completion: { (done: Bool) in
					self.touchpadPointImageView.transform = CGAffineTransform.identity
					self.touchpadPointImageView.isHidden = shouldBeHidden
				})
			} else {
				// Animate the movement of the indicator
				UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState], animations: {
					self.view.layoutIfNeeded()
				}, completion: nil)
			}
			
			self.lastPoint = point
		}
		
		controller.touchpad.button.valueChangedHandler = { (button: DDControllerButton, pressed: Bool) in
			self.showPress(layer: self.touchpadButtonOverlay, pressed: pressed)
		}
		
		controller.appButton.valueChangedHandler = { (button: DDControllerButton, pressed: Bool) in
			self.showPress(layer: self.appButtonOverlay, pressed: pressed)
		}
		
		controller.homeButton.valueChangedHandler = { (button: DDControllerButton, pressed: Bool) in
			self.showPress(layer: self.homeButtonOverlay, pressed: pressed)
		}
		
		controller.volumeUpButton.valueChangedHandler = { (button: DDControllerButton, pressed: Bool) in
			self.volumeUpImageView.image = !pressed ? #imageLiteral(resourceName: "Volume Up") : #imageLiteral(resourceName: "Volume Up Pressed")
		}
		
		controller.volumeDownButton.valueChangedHandler = { (button: DDControllerButton, pressed: Bool) in
			self.volumeDownImageView.image = !pressed ? #imageLiteral(resourceName: "Volume Down") : #imageLiteral(resourceName: "Volume Down Pressed")
		}
	}
	
	func controllerDidDisconnect(_ notification: Notification) {
		dismiss(animated: true, completion: nil)
	}
	
	func controllerDidUpdateBatteryLevel(_ notification: Notification) {
		guard let controller = notification.object as? DDController else { return }
		guard let battery = controller.batteryLevel else { return }
		print("Controller battery life is \(Int(battery * 100))%")
	}
}

