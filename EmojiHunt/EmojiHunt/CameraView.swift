//
//  CameraView.swift
//  EmojiHunt
//
//  Created by manvendu pathak  on 09/08/24.
//

import SwiftUI

struct CameraView: View {
    @State var timeRemaining = 10
    @State var timer = Timer.publish (every: 1, on: .main, in: .common).autoconnect()
    
    @State var emojiStatus = EmojiSearch.searching
    
    var emojiObjects = [EmojiModel(emoji: "💻", emojiName: "laptop"),
                        EmojiModel(emoji: "👓", emojiName: "glasses"),
                        EmojiModel(emoji: "🍾", emojiName: "bottle"),
                        EmojiModel(emoji: "🌳", emojiName: "tree"),
                        EmojiModel(emoji: "📚", emojiName: "book"),
                        EmojiModel(emoji: "✍️", emojiName: "pen"),
                        EmojiModel(emoji: "📲", emojiName: "Phone")
                       ]
    
    @State var currentLevel = 0
    @State var showNext = false
        var body: some View {
            NavigationView{
                ZStack {
                    if showNext || emojiStatus == .found{
                        Button(action: {
                            
                            if self.currentLevel == self.emojiObjects.count - 1{
                                self.emojiStatus = .gameOver
                            }
                            else{
                                self.currentLevel = self.currentLevel + 1
                                self.timeRemaining = 10
                                self.emojiStatus = .searching
                                self.showNext = false
                                self.instantiateTimer()
                            }
                            
                        }) {
                            Text("NEXT")
                                .padding()
                                .font(.largeTitle)
                                .background(Color.red)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                        }
                        
                    }
                    else{
                        CustomCameraRepresentable(emojiString: emojiObjects[currentLevel].emojiName, emojiFound: $emojiStatus)
                    }
                    VStack(alignment: .center, spacing: 16){
                        Spacer()
                        if self.emojiStatus == .gameOver{
                            Button(action: {
                                self.currentLevel = 0
                                self.timeRemaining = 10
                                self.emojiStatus = .searching
                                self.showNext = false
                                self.instantiateTimer()

                            }) {
                                Text("GAME OVER. TAP to RETRY")
                                    .padding()
                                    .font(.custom("Fiendish", size: 20))
                                    .background(Color.green)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(3)
                            }
                        }
                        else{
                            if self.emojiStatus == .searching{
                                
                                Text("\(timeRemaining)")
                                    .font(.system(size:50, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                                    .onReceive(timer) { _ in
                                        
                                        if self.emojiStatus == .found{
                                            self.cancelTimer()
                                            self.timeRemaining = 10
                                            
                                        }
                                        else {
                                            if self.timeRemaining > 0 {
                                                self.timeRemaining -= 1
                                            }
                                            else{
                                                self.emojiStatus = .notFound
                                                self.showNext = true
                                            }
                                        }
                                }
                                
                                Text("Search for the given EMOJI")
                                    .font(.custom("Fiendish", size: 30))
                                    .foregroundColor(.yellow)
                                    .multilineTextAlignment(.center)
                                    
                                
                               
                            }
                            
                            emojiResultText()
                        }
                    }
                }
            }
        }
        
        func instantiateTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        }
        
        func cancelTimer() {
          self.timer.upstream.connect().cancel()
        }
        
        func emojiResultText() -> Text {
               switch emojiStatus {
               case .found:
                return Text("Yippi! YOU FOUND \(emojiObjects[currentLevel].emoji) ")
                    .font(.custom("Fiendish", size: 30))
                    .fontWeight(.bold)
               case .notFound:
                    return Text("\(emojiObjects[currentLevel].emoji) NOT FOUND")
                    .font(.custom("Fiendish", size: 30))
                    .foregroundColor(.red)
                    .fontWeight(.bold)
               default:
                    return Text(emojiObjects[currentLevel].emoji)
                    .font(.system(size:50, design: .rounded))
                    .fontWeight(.bold)
                
                }
            
    }
}

#Preview {
    CameraView()
}



enum EmojiSearch{
    case found
    case notFound
    case searching
    case gameOver
}

struct EmojiModel {
    var emoji: String
    var emojiName: String
}


struct CustomCameraRepresentable: UIViewControllerRepresentable {
    
    var emojiString: String
    @Binding var emojiFound: EmojiSearch
    
    func makeUIViewController(context: Context) -> CameraVC {
        let controller = CameraVC(emoji: emojiString)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ cameraViewController: CameraVC, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(emojiFound: $emojiFound)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, EmojiFoundDelegate {
        
        @Binding var emojiFound: EmojiSearch
        
        init(emojiFound: Binding<EmojiSearch>) {
            _emojiFound = emojiFound
        }
        
        func emojiWasFound(result: Bool) {
            print("emojiWasFound \(result)")
            emojiFound = .found
        }
        
    }
}
