//
//  Created by Evhen Gruzinov on 19.04.2023.
//

import SwiftUI

struct LoginSceneView: View {
    @Binding var applicationSettings: ApplicationSettings
    @State var isShovingImagePopover: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
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
                                HStack(spacing: 0) {
                                    Text("Photo by ")
                                    Link(destination: URL(string: "https://unsplash.com/@nicolesaavedra17")!) {
                                        Text("Nicole Saavedra on Unsplash")
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)

                            }

                        }

                    Text("Convenient place for storing photos").font(.title).bold()
                        .multilineTextAlignment(.center)
                }

                Spacer()

                VStack {
                    Text("Login or sign up to synchronize photos between your devices").font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)

                    HStack {
                        NavigationLink {
                            SignInView(applicationSettings: $applicationSettings)
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
                        withAnimation {
                            applicationSettings.isFirstLaunch.toggle()
                        }
                    } label: {
                        Text("Continue in offline mode")
                    }
                    .padding(.top, 10)
                }
            }
            .foregroundColor(.white)
        .background(Color("Teal"), ignoresSafeAreaEdges: .all)
        }
        .accentColor(.white)
    }
}

struct LoginSceneView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSceneView(applicationSettings: .constant(ApplicationSettings()))
    }
}
