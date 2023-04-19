//
//  Created by Evhen Gruzinov on 19.04.2023.
//

import SwiftUI
import Firebase

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dispayingSettings: DispayingSettings
    @State var email: String = ""
    @State var password: String = ""
    @Binding var applicationSettings: ApplicationSettings
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            Text("Hello Again!").font(.title).bold()
                .multilineTextAlignment(.center)
            Text("Welcome back, you've been missed!").font(.title2)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        
            
            VStack(spacing: 10) {
                TextField("Login", text: $email)
                    .padding(10)
                    .background(.white)
                    .cornerRadius(10)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .padding(10)
                    .background(.white)
                    .cornerRadius(10)
                    .autocapitalization(.none)
                
                Button {
                    signIn()
                } label: {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
                
                .padding(.vertical, 15)
                .foregroundColor(.black)
                .background(.white)
                .cornerRadius(10)
            }
            .foregroundColor(.black)
            .padding(.horizontal, 50)
            .font(.title2)
            
            Spacer()
            
            Text("Or continue with")
                .font(.title3)
                        
            HStack {
                Button {
                    
                } label: {
                    Text("G")
                }
                .frame(width: 50, height: 50)
//                .padding(.vertical, 15)
                .foregroundColor(.black)
                .background(.white)
                .cornerRadius(10)
            }
            

        }
        .foregroundColor(.white)
        .background(Color("Teal"), ignoresSafeAreaEdges: .all)
    }
    
    private func signIn() {
        print("printing")
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let result {
                withAnimation {
                    applicationSettings.userUid = result.user.uid
                    applicationSettings.isFirstLaunch = false
                    applicationSettings.isOnlineMode = true
                    applicationSettings.save()
                    
                    dispayingSettings.isShowingInfoBar.toggle()
                    dispayingSettings.infoBarFinal = true
                    dispayingSettings.infoBarData = "Success Signing In"
                    dispayingSettings.infoBarProgress = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { dispayingSettings.isShowingInfoBar.toggle() }
                }

                dismiss()
            } else {
                print(error as Any)
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView( applicationSettings: .constant(ApplicationSettings()))
    }
}
