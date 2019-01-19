//
//  AlarmViewController.swift
//  HelloAlarm
//
//  Created by Nikita Somenkov on 19/01/2019.
//  Copyright © 2019 Nikita Somenkov. All rights reserved.
//

import UIKit
import UserNotifications

class AlarmViewController: UIViewController {
    struct ButtonTitle {
        static let set = "Set Alarm"
        static let cancel = "Cancel"
    }

    var currectAlarm: Alarm? {
        didSet {
            if let date = currectAlarm?.date {
                label?.text = "Alarm set to \(hmFormatter.string(from: date))"
                label?.layer.opacity = 1.0
                button?.setTitle(ButtonTitle.cancel, for: .normal)
            } else {
                label?.layer.opacity = 0.0
                button?.setTitle(ButtonTitle.set, for: .normal)
            }
        }
    }
    var datePicker: UIDatePicker?
    var button: UIButton?
    var imageView: UIImageView?
    var label: UILabel?
    var guide: UILayoutGuide {
        return view.safeAreaLayoutGuide
    }
    var hmFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


// MARK: ... Load Views
extension AlarmViewController {
    override func loadView() {
        loadMainView()
        loadDatePicker()
        loadActivateAlarmButton()
        loadLabel()
        loadAlarm()
    }
    
    func loadAlarm() {
        if let date = searchNotification(id: Alarm.defaultIdentifier) {
            currectAlarm = Alarm(identifier: Alarm.defaultIdentifier, date: date)
        }
    }
    
    func loadMainView() {
        view = UIView()
        
        let imageView = UIImageView()
        
        if let image = UIImage(contentsOfFile: "\(Bundle.main.bundlePath)/background.png") {
            imageView.image = image
            imageView.contentMode = .left
        } else {
            print("Fail while loading background image, we will use backgroundColor insted")
            imageView.backgroundColor = #colorLiteral(red: 0, green: 0.2684682608, blue: 0.4762560725, alpha: 1)
        }
    
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        self.imageView = imageView
        
        UIView.animate(withDuration: 70.0, delay: 0, options: [.repeat, .autoreverse, .curveLinear], animations: {
            self.imageView?.frame = CGRect(x: 500, y: 0, width: 0, height: 0)
        })
    }
    
    func loadDatePicker() {
        let datePicker = UIDatePicker()
        
        datePicker.setValue(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), forKeyPath: "textColor")
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        view.addSubview(datePicker)
    
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerXAnchor.constraint(equalTo: guide.centerXAnchor, constant: 0).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: 0).isActive = true
    
        self.datePicker = datePicker
    }
    
    func loadActivateAlarmButton() {
        let button = AnimatedHighlightButton()
        
        button.layer.cornerRadius = 5
        button.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        button.setTitle(ButtonTitle.set, for: .normal)
        button.setTitleColor(view.backgroundColor, for: .normal)
        button.addTarget(self, action: #selector(activeAlarmButton), for: .touchUpInside)
     
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalToSystemSpacingAfter: guide.leftAnchor, multiplier: 2.0).isActive = true
        guide.rightAnchor.constraint(equalToSystemSpacingAfter: button.rightAnchor, multiplier: 2.0).isActive = true
        guide.bottomAnchor.constraint(equalToSystemSpacingBelow: button.bottomAnchor, multiplier: 3.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
    
        self.button = button
    }
    
    func loadLabel() {
        let label = UILabel()
        
        label.textColor = .white
        label.textAlignment = .center
        label.layer.opacity = 0.0
        view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalToSystemSpacingAfter: guide.leftAnchor, multiplier: 2.0).isActive = true
        guide.rightAnchor.constraint(equalToSystemSpacingAfter: label.rightAnchor, multiplier: 2.0).isActive = true
        label.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 10.0).isActive = true
        
        self.label = label
    }
}

// MARK: ... Actions
extension AlarmViewController {
    @objc func activeAlarmButton() {
        if let identifier = currectAlarm?.identifier {
            removeNotification(id: identifier)
            return
        }
        
        guard let date = datePicker?.date else {
            return
        }
        self.createNotification(for: date, id: Alarm.defaultIdentifier)
    }
    
    @objc func dateChanged() {
        if currectAlarm != nil {
            return
        }
        
        guard let date = datePicker?.date else {
            return
        }
        
        label?.text = "Wake up \(hmFormatter.string(from: date))"
        UIView.animate(withDuration: 2.0) {
            self.label?.layer.opacity = 1.0
        }
        UIView.animate(withDuration: 2.0, delay: 2.0, options: [], animations: {
            self.label?.layer.opacity = 0.0
        })
    }
}

extension AlarmViewController {
    func createNotification(for date: Date, id: String) {
        currectAlarm = Alarm(identifier: id, date: date)
        
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = "Wake up"
        content.sound = UNNotificationSound.default
        
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        
        let center = UNUserNotificationCenter.current()
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger)) { error in
            if let error = error {
                self.currectAlarm = nil
                print(error)
            }
        }
    }
    
    func removeNotification(id: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
        currectAlarm = nil
    }
    
    func searchNotification(id: String) -> Date? {
        let center = UNUserNotificationCenter.current()
        var request: UNNotificationRequest?
        var done = false
        
        center.getPendingNotificationRequests(completionHandler: { requests in
            request = requests.first { $0.identifier == id }
            done = true
        })
        
        // waiting stupid hack
        while (!done) { }
        if let trigger = request?.trigger as? UNCalendarNotificationTrigger {
            return Calendar.current.date(from: trigger.dateComponents)
        }
        
        return nil
    }
    
    func notificationDidReceive(id: String) {
        if currectAlarm?.identifier == id {
            currectAlarm = nil
        }
    }
}
