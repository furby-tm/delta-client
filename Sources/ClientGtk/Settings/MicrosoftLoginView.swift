import SwiftCrossUI
import DeltaCore

enum MicrosoftState {
  case authorizingDevice
  case login(MicrosoftDeviceAuthorizationResponse)
  case authenticatingUser

  case error(String)
}

class MicrosoftLoginViewState: Observable {
  @Observed var state = MicrosoftState.authorizingDevice
}

struct MicrosoftLoginView: View {
  var completionHandler: (Account) -> Void

  var state = MicrosoftLoginViewState()

  public init(_ completionHandler: @escaping (Account) -> Void) {
    self.completionHandler = completionHandler
    authorizeDevice()
  }
  
  var body: some ViewContent {
    VStack {
      switch state.state {
        case .authorizingDevice:
          Text("Fetching device authorization code")
        case .login(let response):
          Text(response.message)
          Button("Done") {
            state.state = .authenticatingUser
            authenticate(with: response)
          }
        case .authenticatingUser:
          Text("Authenticating...")
        case .error(let message):
          Text(message)
      } 
    }
  }

  func authorizeDevice() {
    Task {
      do {
        let response = try await MicrosoftAPI.authorizeDevice()
        state.state = .login(response)
      } catch {
        state.state = .error("Failed to authorize device: \(error)")
      }
    }
  }

  func authenticate(with response: MicrosoftDeviceAuthorizationResponse) {
    Task {
      let account: MicrosoftAccount
      do {
        let accessToken = try await MicrosoftAPI.getMicrosoftAccessToken(response.deviceCode)
        account = try await MicrosoftAPI.getMinecraftAccount(accessToken)
      } catch {
        guard case .failedToGetXSTSToken = error as? MicrosoftAPIError else {
          state.state = .error("Failed to authenticate Microsoft account: \(error)")
          return
        }

        // TODO: Add localized descriptions to all authentication related errors
        // XSTS errors are the most common so they get nice user-friendly errors
        state.state = .error("Failed to get XSTS token: \(error)")
        return
      }

      completionHandler(Account.microsoft(account))
    }
  }
}
