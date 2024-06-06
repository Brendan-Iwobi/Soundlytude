//
//  TextArea.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 11/6/22.
//

import SwiftUI

struct TextArea: View {
    @Binding var text: String
    let placeholder: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(placeholder)
                .foregroundColor(Color.accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            TextEditor(text: $text)
                .padding(4)
        }
        .font(.body)
    }
}

struct TextFieldModifier: ViewModifier {
    let color: Color
    let padding: CGFloat // <- space between text and border
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, padding)
            .overlay(RoundedRectangle(cornerRadius: 15)
                .stroke(color, lineWidth: lineWidth).offset(y: 0.5)
            )
    }
}

extension View {
    func customTextField(color: Color = .secondary, padding: CGFloat = 3, lineWidth: CGFloat = 1.0) -> some View { // <- Default settings
        self.modifier(TextFieldModifier(color: color, padding: padding, lineWidth: lineWidth))
    }
}
