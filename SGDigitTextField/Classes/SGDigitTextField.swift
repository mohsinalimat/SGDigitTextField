//
//  SGDigitTextField.swift
//
//  Created by Soner Guler on 14.09.2019.
//

import UIKit

@IBDesignable
open class SGDigitTextField: UITextField {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBInspectable
    var digitCount: Int = 0 {
        didSet {
            configure(with: digitCount)
        }
    }

    /// Digit label normal border color
    @IBInspectable
    var borderColor: UIColor = .gray {
        didSet {
            reload()
        }
    }

    /// Digit label highlighted border color
    @IBInspectable
    var highlightedBorderColor: UIColor = .red {
        didSet {
            reload()
        }
    }

    @IBInspectable
    var borderWidth: CGFloat = 1.0 {
        didSet {
            reload()
        }
    }

    @IBInspectable
    var cornerRadius: CGFloat = 10.0 {
        didSet {
            reload()
        }
    }


    /// When isSecureTextEntry is selected, this character will be shown
    var secureCharacter: String = "●"

    private var labels = [UILabel]()
    private var stackView: UIStackView?


    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        delegate = self
        keyboardType = .numberPad
        textColor = .clear
        tintColor = .clear
        if #available(iOS 12.0, *) {
            textContentType = .oneTimeCode
        }
        addTarget(self, action: #selector(textChanged), for: .editingChanged)
        addTarget(self, action: #selector(editingBegin), for: .editingDidBegin)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        if digitCount > 0 {
            configure(with: digitCount)
        }
    }


    /// Configures the textfield according to digit count
    ///
    /// - Parameter count: Digit count
    func configure(with count: Int) {
        createStackView(for: count)
    }

    /// Reloads the content
    func reload() {
        configure(with: digitCount)
    }

    /// Responsible for creating and adding stackview on the textfield
    private func createStackView(for count: Int) {

        let stack = UIStackView(frame: bounds)
        stack.spacing = 5
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.isUserInteractionEnabled = false

        labels.removeAll()
        for _ in 1...count {
            let lbl = createLabel()
            labels.append(lbl)
            stack.addArrangedSubview(lbl)
        }
        stackView?.removeFromSuperview()
        stackView = stack
        addSubview(stack)
    }

    /// Returns label with format
    private func createLabel() -> UILabel {
        let lbl = UILabel()
        lbl.layer.cornerRadius = cornerRadius
        lbl.layer.borderColor = borderColor.cgColor
        lbl.layer.borderWidth = borderWidth
        lbl.font = font
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = false
        return lbl
    }

    /// Update current label focus.
    private func updateLabelFocus(focus: Bool = true) {
        labels.forEach {
            $0.layer.borderColor = borderColor.cgColor
        }

        if !focus { return }

        guard let text = text, labels.indices.contains(text.count) else { return  }

        let focusedLabel = labels[text.count]
        focusedLabel.layer.borderColor = highlightedBorderColor.cgColor
    }

    /// Triggered when text changed
    @IBAction private func textChanged() {
        debugPrint("text: \(text ?? "-")")
        guard let text = text, text.count <= labels.count else { return }

        for i in 0 ..< labels.count {
            let lbl = labels[i]

            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                let char = isSecureTextEntry ? secureCharacter : String(text[index])
                lbl.text = char
            }
        }
        updateLabelFocus()
    }

    /// Triggered when editing begin
    @IBAction private func editingBegin() {
        updateLabelFocus()
    }

    /// Triggered when keyboard is about to hide
    @objc func keyboardWillHide(notification: Notification) {
        updateLabelFocus(focus: false)
    }
}

extension SGDigitTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {

        guard let text = text else { return false }

        if string == "", labels.indices.contains(text.count - 1) {
            let lastLabel = labels[text.count - 1]
            lastLabel.text = nil
            self.text?.removeLast()
            updateLabelFocus()
            return false
        }

        guard text.count < labels.count else { return false }

        return true
    }
}
