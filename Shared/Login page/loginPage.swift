//
//  loginPage.swift
//  Soundlytude (iOS)
//
//  Created by DJ bon26 on 10/17/22.
//

import SwiftUI

struct loginPage: View {
    @StateObject var checkEmail = checkEmailClass()
    @StateObject var checkLogin = checkIfLoginExistClass()
    @StateObject var sendConfirmationCode = sendLoginConfirmationCode()
    
    @State private var presentAlert = false
    @State private var presentAlertTitle = ""
    @State private var presentAlertMessage = "Something isn't right on your end"
    @State private var presentForgotPassword = false
    @State private var presentConfirmCode = false
    
    @State private var sendLoginDetailsLabel:String = "Send login details"
    @State private var sendLoginDetailsDisable = false
    @State private var loginLabel:String = "Log In"
    @State private var loginDisable = false
    @State private var confirmCodeLabel:String = "Confirm"
    @State private var confirmCodeDisable = false
    @State private var disableAllInputs = false
    
    @State private var emailValue: String = ""
    @State private var codeValue: String = ""
    @State private var usernameValue: String = ""
    @State private var passwordValue: String = ""
    
    @FocusState private var emailInputFocused: Bool
    @FocusState private var codeInputFocused: Bool
    @FocusState private var usernameInputFocused: Bool
    @FocusState private var passwordInputFocused: Bool
    
    @State var isRequestTimeout:Double = 0.0
    
    @State var loginSuccess: Bool = false
    
    var loginIsValid: Bool {
        if (usernameValue == "" || passwordValue == "" || loginDisable || disableAllInputs) {
            return false
        }else {
            return true
        }
    }
    
    var sendLoginDetailsIsValid: Bool {
        if (emailValue == "" || sendLoginDetailsDisable || disableAllInputs) {
            return false
        }else {
            return true
        }
    }
    
    var confirmCodeIsValid: Bool {
        if (codeValue == "" || confirmCodeDisable || disableAllInputs) {
            return false
        }else {
            return true
        }
    }
    
    let verticalPaddingForForm = 40.0
    
    var body: some View {
        NavigationView{
            VStack{
                if loggedInUsers.isEmpty{
                    LoginView()
                } else {
                    List{
                        ForEach(0..<loggedInUsers.count, id:\.self){i in
                            let x = loggedInUsers[i]
                            Button {
                                local.set(x._id, forKey: "soundlytudeUserId")
                                local.set(x.artistName, forKey: "currentUserArtistName")
                                local.set(x.password, forKey: "currentUserPassword")
                                local.set(x.slug, forKey: "currentUsername")
                                local.set(x.email, forKey: "currentUserEmail")
                                local.set(x.pimage, forKey: "currentUserArtistPfp")
                                newlyUpdatedPfpUrl = local.string(forKey: "currentUserArtistPfp") ?? ""
                                loginSuccess = true
                                
                            } label: {
                                HStack{
                                    circleImage40by40(urlString: x.pimage)
                                    VStack(alignment: .leading){
                                        Text(x.artistName)
                                            .font(.body)
                                            .fontWeight(.bold)
                                        Text(x.slug)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        NavigationLink {
                            LoginView()
                        } label: {
                            Text("Add account")
                                .padding()
                        }
                        
                    }.navigationTitle("Saved accounts")
                }
            }
        }
        VStack{}
            .fullScreenCover(isPresented: $loginSuccess, content: {
                ContentView()
            })
    }
    
    //MARK: Login view
    @ViewBuilder
    func LoginView() -> some View {
        ZStack{
            VStack(spacing: CGFloat(verticalPaddingForForm)) {
                Spacer().frame(height: 40)
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                HStack {
                    Image(systemName: "person")
                        .font(Font.headline.weight(.bold))
                    TextField("", text: $usernameValue)
                        .textContentType(.username)
                        .keyboardType(.default)
                        .font(Font.headline.weight(.bold))
                        .focused($usernameInputFocused)
                        .placeholder(when: usernameValue.isEmpty) {
                            Text("Username").fontWeight(.bold).opacity(0.25)
                        }
                        .disableAutocorrection(true)
                        .disabled(disableAllInputs)
                }
                .padding()
                .background(Color("BlackWhite").opacity(0.1))
                .cornerRadius(100)
                .onTapGesture {
                    usernameInputFocused = true
                }
                HStack {
                    Image(systemName: "key")
                        .font(Font.headline.weight(.bold))
                    SecureField("", text: $passwordValue)
                        .textContentType(.password)
                        .font(Font.headline.weight(.bold))
                        .focused($passwordInputFocused)
                        .placeholder(when: passwordValue.isEmpty) {
                            Text("Password").fontWeight(.bold).opacity(0.25)
                        }
                        .disableAutocorrection(true)
                        .disabled(disableAllInputs)
                }
                .padding()
                .background(Color("BlackWhite").opacity(0.1))
                .cornerRadius(100)
                .onTapGesture {
                    passwordInputFocused = true
                }
                Button{
                    presentForgotPassword = true
                    usernameInputFocused = false
                    passwordInputFocused = false
                } label: {
                    Text("Forgot Password or Username?")
                }
                .disabled(disableAllInputs)
                NavigationLink("Sign up to Soundlytude", destination: signUpPage())
                    .disabled(disableAllInputs)
                Button{
                    loginSuccess = true
                } label: {
                    Text("Test login")
                }
                .disabled(disableAllInputs)
                Spacer()
                Button{
                    login()
                } label: {
                    Text(loginLabel)
                        .foregroundColor((loginIsValid) ? Color("WhiteBlack") : Color.white)
                        .padding()
                        .frame(width: viewableWidth - 80)
                }
                .background((loginIsValid) ? Color("BlackWhite") : Color(hexStringToUIColor(hex: "#aaaaaa")))
                .cornerRadius(100)
                .disabled((loginIsValid) ? false : true)
                .padding(.bottom, 50)
            }
            forgotPasswordView()
                .opacity(presentForgotPassword ? 1 : 0)
            confirmCodeView()
                .opacity(presentConfirmCode ? 1 : 0)
        }
        .padding(.horizontal, CGFloat(verticalPaddingForForm))
        .alert(presentAlertTitle, isPresented: $presentAlert, actions: {
            Button("OK", role: .cancel, action: {withError=""})
        }, message: {
            Text(presentAlertMessage)
        })
    }
    
    //MARK: Forgot Password view
    @ViewBuilder
    func forgotPasswordView() -> some View {
        VStack(spacing: verticalPaddingForForm){
            Spacer().frame(height: 40)
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Enter the email you signed up with, we'll send your login details to you")
                .padding(.vertical)
            HStack {
                Image(systemName: "mail")
                    .font(Font.headline.weight(.bold))
                TextField("", text: $emailValue)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .font(Font.headline.weight(.bold))
                    .focused($emailInputFocused)
                    .placeholder(when: emailValue.isEmpty) {
                        Text("Email").fontWeight(.bold).opacity(0.25)
                    }
                    .disabled(disableAllInputs)
            }
            .padding()
            .background(Color("BlackWhite").opacity(0.1))
            .cornerRadius(100)
            .onTapGesture {
                emailInputFocused = true
            }
            Button{
                forgotPassword()
            } label: {
                Text(sendLoginDetailsLabel)
                    .foregroundColor((sendLoginDetailsIsValid) ? Color("WhiteBlack") : Color.white)
                    .padding()
                    .frame(width: viewableWidth - 80)
            }
            .background((sendLoginDetailsIsValid) ? Color("BlackWhite") : Color(hexStringToUIColor(hex: "#aaaaaa")))
            .cornerRadius(100)
            .disabled((sendLoginDetailsIsValid) ? false : true)
            Spacer()
            Button{
                presentForgotPassword = false
                emailInputFocused = false
            } label: {
                Text("Cancel")
                    .foregroundColor(Color.red)
                    .padding()
                    .padding(.horizontal, 40)
            }
            .cornerRadius(100)
            .padding(.bottom, 50)
        }
        .background(Color("WhiteBlack"))
    }
    
    //MARK: Confirm Code view
    @ViewBuilder
    func confirmCodeView() -> some View {
        VStack(spacing: verticalPaddingForForm){
            Spacer().frame(height: 40)
            Text("Confirm Login")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Enter the 6-digit code sent to \(loginUserEmail)")
                .padding(.vertical)
            HStack {
                Image(systemName: "number")
                    .font(Font.headline.weight(.bold))
                TextField("", text: $codeValue)
                    .keyboardType(.numberPad)
                    .font(Font.headline.weight(.bold))
                    .focused($codeInputFocused)
                    .placeholder(when: codeValue.isEmpty) {
                        Text("6-digit code").fontWeight(.bold).opacity(0.25)
                    }
                    .disabled(disableAllInputs)
            }
            .padding()
            .background(Color("BlackWhite").opacity(0.1))
            .cornerRadius(100)
            .onTapGesture {
                codeInputFocused = true
            }
            Button{
                confirmCode()
            } label: {
                Text(confirmCodeLabel)
                    .foregroundColor((confirmCodeIsValid) ? Color("WhiteBlack") : Color.white)
                    .padding()
                    .frame(width: viewableWidth - 80)
            }
            .background((confirmCodeIsValid) ? Color("BlackWhite") : Color(hexStringToUIColor(hex: "#aaaaaa")))
            .cornerRadius(100)
            .disabled((confirmCodeIsValid) ? false : true)
            Spacer()
        }
        .background(Color("WhiteBlack"))
    }
    
    func confirmCode(){
        confirmCodeLabel = "Confirming..."
        confirmCodeDisable = true
        disableAllInputs = true
        if codeValue ==  generatedCode{
            //MARK: Login function
            loggedInUsers.append(User(
                _id: loginUserSoundlytudeId,
                artistName: loginArtistName,
                password: loginPassword,
                slug: loginUsername,
                email: loginUserEmail,
                pimage: loginArtistPfp)
            )
            local.set(loginUserSoundlytudeId, forKey: "soundlytudeUserId")
            local.set(loginArtistName, forKey: "currentUserArtistName")
            local.set(loginPassword, forKey: "currentUserPassword")
            local.set(loginUsername, forKey: "currentUsername")
            local.set(loginUserEmail, forKey: "currentUserEmail")
            local.set(loginArtistPfp, forKey: "currentUserArtistPfp")
            if let data = try? PropertyListEncoder().encode(loggedInUsers) {
                local.set(data, forKey: "LoggedInUsers")
            }
            confirmCodeLabel = "Confirm"
            confirmCodeDisable = false
            disableAllInputs = true
            loginSuccess = true
        }
        else{
            confirmCodeLabel = "Confirm"
            confirmCodeDisable = false
            disableAllInputs = false
            presentAlertTitle = "Something isn't right on your end"
            presentAlertMessage = "This code does not match the code we sent to \(loginUserEmail)"
            presentAlert = true
        }
    }
    func forgotPassword() {
        sendLoginDetailsLabel = "Sending login details..."
        sendLoginDetailsDisable = true
        disableAllInputs = true
        checkEmail.check(email: emailValue)
        waitForCheckEmail()
        func waitForCheckEmail(){
            if (checkForEmailIsPaused) { //is still sending the comfirmation email code
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if isRequestTimeout > Double(15){
                        isRequestTimeout = 0
                        presentAlertTitle = "Request timeout"
                        presentAlertMessage = "Sending your login details took more than 15 seconds, please check your internet connection and try again"
                        presentAlert = true
                        sendLoginDetailsLabel = "Send login details"
                        sendLoginDetailsDisable = false
                        disableAllInputs = false
                    }else{
                        waitForCheckEmail()
                        isRequestTimeout = isRequestTimeout + Double(0.5)
                    }
                }
            } else {
                if noEmailAddressFound {
                    if withError == ""{
                        presentAlertTitle = "Something isn't right on your end"
                        presentAlertMessage = "That email doesn't exist on Soundlytude"
                    }else{
                        presentAlertTitle = "Something isn't right on our end"
                        presentAlertMessage = "\(withError)"
                    }
                    presentAlert = true
                    sendLoginDetailsLabel = "Send login details"
                    sendLoginDetailsDisable = false
                    disableAllInputs = false
                }else{
                    sendLoginDetailsToEmail()
                    waitForSendLoginDetailsToEmail()
                    func waitForSendLoginDetailsToEmail() {
                        if (sendLoginDetailsIsPaused) { //is still sending the login details to email
                            if isRequestTimeout > Double(15){
                                isRequestTimeout = 0
                                presentAlertTitle = "Request timeout"
                                presentAlertMessage = "Sending your login details took more than 15 seconds, please check your internet connection and try again"
                                presentAlert = true
                                sendLoginDetailsLabel = "Send login details"
                                sendLoginDetailsDisable = false
                                disableAllInputs = false
                            }else{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    waitForSendLoginDetailsToEmail()
                                    isRequestTimeout = isRequestTimeout + Double(0.5)
                                }
                            }
                        } else {
                            emailValue = ""
                            emailInputFocused = false
                            sendLoginDetailsLabel = "Send login details"
                            sendLoginDetailsDisable = false
                            presentForgotPassword = false
                            presentAlertTitle = "INFO"
                            presentAlertMessage = "Check your email. Your login details has been sent to \(forgotPasswordUserEmail)"
                            presentAlert = true
                            disableAllInputs = false
                        }
                    }
                }
            }
        }
    }
    
    func login(){
        if loggedInUsers.count > 0{
            for i in 0...(loggedInUsers.count-1) {
                if loggedInUsers[i].slug == usernameValue {
                    presentAlertTitle = "INFO"
                    presentAlertMessage = "This account is already signed in on this device, login through the saved accounts."
                    presentAlert = true
                    loginLabel = "Log In"
                    loginDisable = false
                    disableAllInputs = false
                    return
                }
            }
        }
        loginLabel = "Logging in..."
        loginDisable = true
        checkLogin.check(username: usernameValue, password: passwordValue)
        waitForCheckLogin()
        disableAllInputs = true
        func waitForCheckLogin(){
            if (checkIfLoginExistIsPaused) {
                if isRequestTimeout > Double(15){
                    isRequestTimeout = 0
                    presentAlertTitle = "Request timeout"
                    presentAlertMessage = "Logging you in took more than 15 seconds, please check your internet connection and try again"
                    presentAlert = true
                    loginLabel = "Log In"
                    loginDisable = false
                    disableAllInputs = false
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        waitForCheckLogin()
                        isRequestTimeout = isRequestTimeout + Double(0.5)
                    }
                }
            }else{
                if noUsernameFound {
                    presentAlertTitle = "Something isn't right on your end"
                    presentAlertMessage = "That username does not exist on Soundlytude. Check your spaces, Usernames have no spaces"
                    presentAlert = true
                    loginLabel = "Log In"
                    loginDisable = false
                    disableAllInputs = false
                }else{
                    if passwordDontMatch {
                        presentAlertTitle = "Something isn't right on your end"
                        presentAlertMessage = "The password for that account is incorrect"
                        presentAlert = true
                        loginLabel = "Log In"
                        loginDisable = false
                        disableAllInputs = false
                    }else{
                        loginLabel = "Log In"
                        loginDisable = false
                        disableAllInputs = false
                        sendConfirmationCode.sendConfirmationCode(artistName: loginArtistName, email: loginUserEmail)
                        confirmLogin()
                    }
                }
            }
        }
    }
    
    func confirmLogin(){
        loginLabel = "Sending you a confirmation code..."
        loginDisable = true
        waitForSendCode()
        disableAllInputs = true
        func waitForSendCode(){
            if (sendLoginConfirmationCodeIsPaused) {
                if isRequestTimeout > Double(15){
                    isRequestTimeout = 0
                    presentAlertTitle = "REQUEST TIMEOUT"
                    presentAlertMessage = "Confirming your code took more than 15 seconds, please check your internet connection and try again"
                    presentAlert = true
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        waitForSendCode()
                        isRequestTimeout = isRequestTimeout + Double(0.5)
                    }
                }
            }else{
                loginLabel = "Login"
                loginDisable = false
                disableAllInputs = false
                presentConfirmCode = true
            }
        }
    }
}

struct loginPage_Previews: PreviewProvider {
    static var previews: some View {
        loginPage()
    }
}

struct checkEmailField: Hashable, Codable {
    let _id: String
    let slug: String
    let password: String
    let email: String
}

private var sendLoginDetailsIsPaused = true
private var checkForEmailIsPaused = true
private var noEmailAddressFound = true

private var withError = ""
private var forgotPasswordUsername = ""
private var forgotPasswordPassword = ""
private var forgotPasswordUserEmail = ""

class checkEmailClass: ObservableObject {
    @Published var checkEmailFields: [checkEmailField] = []
    
    func check(email:String) {
        checkForEmailIsPaused = true
        guard let url = URL(string: HttpBaseUrl() + "/_functions/artists?password=G62zOR9ZTlA0Tbcd2TX8&type=filterEq&columnId=email&value=\(email.lowercased().replacingOccurrences(of: " ", with: "+"))&noItems=true") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([checkEmailField].self, from: data)
                DispatchQueue.main.async{
                    self?.checkEmailFields = data
                    checkForEmailIsPaused = false
                    if data.count < 1{
                        noEmailAddressFound = true
                    }else{
                        noEmailAddressFound = false
                        forgotPasswordUsername = data[0].slug
                        forgotPasswordPassword = data[0].password
                        forgotPasswordUserEmail = data[0].email
                    }
                }
            }
            catch {
                checkForEmailIsPaused = false
                noEmailAddressFound = true
                withError = error.localizedDescription
                print(error)
            }
        }
        task.resume()
    }
}

struct currentArtistField: Hashable, Codable {
    let _id: String
    let slug: String
    let password: String
    let artistName: String
    let email: String
    let pimage: String
}

private var checkIfLoginExistIsPaused = true
private var noUsernameFound = true
private var passwordDontMatch = true

class checkIfLoginExistClass: ObservableObject {
    @Published var currentArtistFields: [currentArtistField] = []
    
    func check(username:String, password:String) {
        checkIfLoginExistIsPaused = true
        guard let url = URL(string: HttpBaseUrl() + "/_functions/artists?password=G62zOR9ZTlA0Tbcd2TX8&type=filterEq&columnId=slug&value=\(username.lowercased().replacingOccurrences(of: " ", with: "+"))&noItems=true") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([currentArtistField].self, from: data)
                DispatchQueue.main.async{
                    self?.currentArtistFields = data
                    checkIfLoginExistIsPaused = false
                    if data.count > 0{
                        noUsernameFound = false
                        if password == data[0].password{
                            passwordDontMatch = false
                            loginUsername = data[0].slug
                            loginArtistPfp = data[0].pimage
                            loginPassword = data[0].password
                            loginUserEmail = data[0].email
                            loginArtistName = data[0].artistName
                            loginUserSoundlytudeId = data[0]._id
                        }else{
                            passwordDontMatch = true
                        }
                    }else{
                        noUsernameFound = true
                    }
                }
            }
            catch {
                checkIfLoginExistIsPaused = false
                withError = error.localizedDescription
                print(error)
            }
        }
        task.resume()
    }
}

struct generateCodeField: Hashable, Codable {
    let generatedCode: String
}

private var loginUsername = ""
private var loginPassword = ""
private var loginUserEmail = ""
private var loginArtistName = ""
private var loginArtistPfp = ""
private var loginUserSoundlytudeId = ""
private var sendLoginConfirmationCodeIsPaused = true
private var generatedCode = ""

class sendLoginConfirmationCode: ObservableObject {
    @Published var generateCodeFields: [generateCodeField] = []
    
    func sendConfirmationCode(artistName:String, email: String) {
        sendLoginConfirmationCodeIsPaused = true
        guard let url = URL(string: HttpBaseUrl() + "/_functions/sendEmail?password=1X0lOxbv2D3tL8W0tAPI&type=confirmLogin&email=\(email.lowercased().replacingOccurrences(of: " ", with: "+"))&name=\(artistName.replacingOccurrences(of: " ", with: "+"))") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do
            {
                let data = try JSONDecoder().decode ([generateCodeField].self, from: data)
                DispatchQueue.main.async{
                    self?.generateCodeFields = data
                    sendLoginConfirmationCodeIsPaused = false
                    generatedCode = data[0].generatedCode
                }
            }
            catch {
                sendLoginConfirmationCodeIsPaused = false
                withError = error.localizedDescription
                print(error)
            }
        }
        task.resume()
    }
}

private func sendLoginDetailsToEmail() {
    sendLoginDetailsIsPaused = true
    guard let url = URL(string: HttpBaseUrl() + "/_functions/sendEmail?password=1X0lOxbv2D3tL8W0tAPI&type=loginDetails&email=\(forgotPasswordUserEmail.lowercased().replacingOccurrences(of: " ", with: "+"))&username=\(forgotPasswordUsername.lowercased().replacingOccurrences(of: " ", with: "+"))&pass=\(forgotPasswordPassword)") else {
        return}
    let task = URLSession.shared.dataTask(with: url) { data, _,
        error in
        guard let _ = data, error == nil else {
            return
        }
        sendLoginDetailsIsPaused = false
    }
    task.resume()
}
