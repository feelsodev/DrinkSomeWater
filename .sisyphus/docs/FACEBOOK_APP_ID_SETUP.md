# Facebook App ID 설정 가이드

Instagram Stories 공유 기능을 완전히 활용하려면 Facebook App ID가 필요합니다.

## 1. Facebook Developer 계정 생성

1. [Facebook for Developers](https://developers.facebook.com/) 접속
2. 우측 상단 "시작하기" 클릭
3. Facebook 계정으로 로그인 (없으면 새로 생성)
4. 개발자 계정 등록 완료

## 2. 앱 생성

1. [내 앱](https://developers.facebook.com/apps/) 페이지로 이동
2. "앱 만들기" 버튼 클릭
3. 앱 유형 선택: "기타" 또는 "소비자"
4. 앱 이름 입력 (예: "벌컥벌컥")
5. 연락처 이메일 입력
6. "앱 만들기" 클릭

## 3. App ID 확인

1. 앱 대시보드에서 "설정" > "기본" 클릭
2. 상단에 표시된 "앱 ID" 복사 (숫자로 된 ID)

## 4. iOS 앱에 설정 추가

`ios/Project.swift` 파일의 `infoPlist` 섹션에 추가:

```swift
infoPlist: .extendingDefault(with: [
    // 기존 설정들...
    "FacebookAppID": "YOUR_APP_ID_HERE",
    "CFBundleURLTypes": .array([
        .dictionary([
            "CFBundleURLSchemes": .array([
                .string("fb YOUR_APP_ID_HERE")
            ])
        ])
    ])
])
```

`YOUR_APP_ID_HERE`를 실제 App ID로 교체하세요.

## 5. Instagram 앱 ID 연결 (선택사항)

더 나은 분석을 위해 Instagram 계정 연결:

1. 앱 대시보드에서 "제품 추가" 클릭
2. "Instagram 기본 표시 API" 설정
3. 안내에 따라 Instagram 비즈니스/크리에이터 계정 연결

## 6. 테스트

1. `tuist generate` 실행
2. 앱 빌드 및 실행
3. Instagram이 설치된 실제 기기에서 공유 기능 테스트

## 참고 사항

- Facebook App ID 없이도 기본 공유 기능은 작동합니다
- App ID를 설정하면 공유 분석 및 추적이 가능해집니다
- 앱 스토어 배포 전 Facebook 앱 검토를 받을 필요는 없습니다 (기본 공유 기능만 사용 시)

## 문제 해결

### 공유 후 Instagram이 열리지 않음
- Info.plist에 `instagram-stories` URL scheme이 등록되어 있는지 확인
- 실제 기기에서 테스트 (시뮬레이터에서는 Instagram 설치 불가)

### "앱을 열 수 없음" 오류
- Facebook App ID가 올바르게 설정되었는지 확인
- `tuist generate` 후 클린 빌드 시도

## 관련 문서

- [Instagram Sharing to Stories](https://developers.facebook.com/docs/instagram/sharing-to-stories/)
- [Facebook App ID 설정](https://developers.facebook.com/docs/development/create-an-app/)
