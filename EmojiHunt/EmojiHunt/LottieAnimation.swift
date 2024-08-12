//
//  LottieAnimation.swift
//  EmojiHunt
//
//  Created by manvendu pathak  on 09/08/24.
//

import SwiftUI
import Lottie

struct LottieAnimation: UIViewRepresentable{
    var animationName: String
    var lottieMode: LottieLoopMode
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let lottieAnimationView = LottieAnimationView(name: animationName)
        lottieAnimationView.contentMode = .scaleAspectFit
        lottieAnimationView.loopMode = .loop
        lottieAnimationView.play()
        lottieAnimationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lottieAnimationView)
        NSLayoutConstraint.activate([
            lottieAnimationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            lottieAnimationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        return view
    }
}
