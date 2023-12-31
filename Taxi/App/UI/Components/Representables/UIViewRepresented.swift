//
//  UIViewRepresented.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 19.10.23.
//

import SwiftUI

struct UIViewRepresented<UIViewType: UIView>: UIViewRepresentable {

    let makeUIView: (Context) -> UIViewType
    let updateUIView: (UIViewType, Context) -> Void = { _, _ in }

    func makeUIView(context: Context) -> UIViewType {
        self.makeUIView(context)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        self.updateUIView(uiView, context)
    }
}
