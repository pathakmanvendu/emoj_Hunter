//
//  ContentView.swift
//  EmojiHunt
//
//  Created by manvendu pathak  on 09/08/24.
//

import SwiftUI
import Lottie

struct ContentView: View {
    var body: some View {
        NavigationView {
             VStack{
                Text("Emoji Hunter")
                    .font(.custom("Fiendish", size: 55))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("Color1"))
                
                ZStack{
                     RoundedRectangle(cornerRadius: 40)
                        .fill(Color("Color"))
                        .frame(width: 350, height: 450)
                    
                     VStack{
                          LottieAnimation(animationName: "animation", lottieMode: .loop)
                            .frame(width: 400, height: 350)
                          
                        
                          NavigationLink(destination: CameraView()) {
                              ZStack{
                                Capsule()
                                    .frame(width: 140, height: 50)
                                    .foregroundColor(.white)
                                Text("Start")
                                    .foregroundColor(.black)
                                    .bold()
                                    .font(.title)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
