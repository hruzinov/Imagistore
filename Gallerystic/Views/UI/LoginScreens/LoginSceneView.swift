//
//  Created by Evhen Gruzinov on 19.04.2023.
//

import SwiftUI
import Firebase

struct LoginSceneView: View {
    @Binding var applicationSettings: ApplicationSettings
    @State var email: String = ""
    @State var password: String = ""
    @State var isShovingImagePopover: Bool = false
    
    var body: some View {
        VStack {
            Image("PhotosCollage")
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.main.bounds.width / 1.5)
                .clipped()
                .cornerRadius(10)
                .padding(15)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        isShovingImagePopover.toggle()
                    } label: {
                        Image(systemName: "info.circle.fill")
                    }
                    .padding(20)
                    .alwaysPopover(isPresented: $isShovingImagePopover) {
                        HStack(spacing:0) {
                            Text("Photo by ")
                            Link(destination: URL(string: "https://unsplash.com/@nicolesaavedra17")!) {
                                Text("Nicole Saavedra on Unsplash")
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        
                    }

                }
            
            Spacer()
            
                Text("Convenient place for storing photos").font(.title).bold()
                    .multilineTextAlignment(.center)
            Spacer()
                Text("Login or sign up to synchronize photos between your devices").font(.title3)
                    .multilineTextAlignment(.center)
            
            
            Spacer()
            
            VStack {
                HStack {
                    Button {
                        
                    } label: {
                        Text("Sign In")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(10)
                    
                    Button {
                        
                    } label: {
                        Text("Register")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                }
                .font(.title3)
                .foregroundColor(.white)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding(.horizontal, 50)
                
                
                Button {
                    
                } label: {
                    Text("Continue in offline mode")
                }
                .padding(.top, 10)
            }
        }
        .foregroundColor(.white)
        .background(Color("Teal"), ignoresSafeAreaEdges: .all)
        
    }
    
    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error {
                print(error)
            } else {
                print(result as Any)
            }
        }
    }
}

struct LoginSceneView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSceneView(applicationSettings: .constant(ApplicationSettings()))
    }
}
