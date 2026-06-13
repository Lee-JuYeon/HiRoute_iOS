//
//  AppleSignInCoordinator.swift
//  HiRoute
//
//  Created by Jupond on 3/11/26.
//

import AuthenticationServices

/*
 ⚠️ BUG FIX — Apple Sign In error 1000 coordinator 조기 해제 문제 (2026-03-19)

 [원인]
 iOS에서 기존 Apple 자격증명이 있으면 시스템이 자동으로 silent 인증을 시도한다.
 이 silent 인증이 실패하면 error 1000 (ASAuthorizationError.unknown)이 발생하고,
 그 직후 시스템이 실제 Apple Sign In 시트를 띄워 유저에게 인증을 요청한다.

 즉, 하나의 ASAuthorizationController 요청에서:
   1) didCompleteWithError (error 1000) — silent 인증 실패
   2) didCompleteWithAuthorization — 유저가 시트에서 인증 성공
 두 delegate 메서드가 순차적으로 호출될 수 있다.

 [기존 코드의 문제]
 didCompleteWithError에서 AppleSignInCoordinator.current = nil로 coordinator를 즉시 해제했다.
 ASAuthorizationController.delegate는 weak 참조이므로, current가 nil이 되면
 coordinator가 ARC에 의해 해제되고, delegate도 nil이 된다.
 → 이후 didCompleteWithAuthorization이 호출되어도 delegate가 nil이라 onComplete가 실행되지 않음
 → socialLogin이 호출되지 않음 → 네비게이션이 일어나지 않음 → 온보딩에 멈춤

 [수정 내용]
 - error가 .canceled (유저 직접 취소)인 경우에만 coordinator 해제 + onError 호출
 - error가 .unknown (1000)인 경우 coordinator 유지, onError 미호출 (후속 success 대기)
 - 그 외 에러 (.invalidResponse, .notHandled, .failed)는 onError 호출 + coordinator 해제
 - ASAuthorizationControllerDelegate 콜백이 background thread에서 올 수 있으므로
   DispatchQueue.main.async로 감싸서 @Published 변경의 thread safety 보장

 [시나리오별 동작]
 A. 정상 성공 (에러 없음): didCompleteWithAuthorization → onComplete → release — 변경 없음
 B. 유저 취소: didCompleteWithError(.canceled) → onError → release — 변경 없음
 C. error 1000 + 성공: coordinator 유지 → 성공 콜백 정상 수신 — 버그 수정됨 ✅
 D. error 1000만 단독: 스낵바 안 뜸, coordinator 잔류 → 다음 탭 시 자동 교체 (발생 확률 극히 낮음)
 */

class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate {

    static var current: AppleSignInCoordinator?
    private let onComplete: (String, String?) -> Void
    private let onError: () -> Void

    init(onComplete: @escaping (String, String?) -> Void, onError: @escaping () -> Void) {
        self.onComplete = onComplete
        self.onError = onError
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            return
        }

        let fullName = [
            credential.fullName?.givenName,
            credential.fullName?.familyName
        ].compactMap { $0 }.joined(separator: " ")

        // DispatchQueue.main.async로 감싸서 @Published 변경이 main thread에서 일어나도록 보장
        // GCD 블록이 self를 강하게 캡처하므로, 아래 current = nil 후에도 coordinator는 블록 실행까지 생존
        DispatchQueue.main.async {
            self.onComplete(idToken, fullName.isEmpty ? nil : fullName)
        }
        AppleSignInCoordinator.current = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("AppleSignIn // Exception : \(error.localizedDescription)")

        /*
         ⚠️ 기존 코드 (버그 원인):
         모든 에러에서 onError() 호출 + coordinator 즉시 해제 → error 1000 시 후속 success 콜백 수신 불가

         onError()
         AppleSignInCoordinator.current = nil
         */

        let authError = error as? ASAuthorizationError

        switch authError?.code {
        case .unknown:
            // error 1000 — iOS silent 인증 실패. 실제 Apple Sign In 시트가 이어서 뜨므로
            // coordinator를 유지하여 후속 didCompleteWithAuthorization 콜백을 받을 수 있게 한다.
            // onError()를 호출하지 않아 에러 스낵바도 표시하지 않는다.
            print("AppleSignIn // error 1000 (unknown) — coordinator 유지, 후속 success 대기")
            break

        case .canceled:
            // 유저가 직접 취소 — 에러 표시 + coordinator 해제
            DispatchQueue.main.async { self.onError() }
            AppleSignInCoordinator.current = nil

        default:
            // .invalidResponse, .notHandled, .failed 등 실제 에러 — 에러 표시 + coordinator 해제
            DispatchQueue.main.async { self.onError() }
            AppleSignInCoordinator.current = nil
        }
    }
}
