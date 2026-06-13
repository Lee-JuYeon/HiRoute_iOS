# HiRoute_iOS

| 항목               | 내용                                                    |
|--------------------|---------------------------------------------------------|
| **협업 기간**        | 2025.05.28 ~ 2025.08.03                                 |
| **팀 구성**         | 디자이너: 박서연<br>백엔드: 이봉희<br>PM: 이동환<br>모바일 프론트엔드: 이주연 |
| **앱의 목적**        | 단기간 여행을 위한 **추천 기반 일정 관리 어플리케이션**                         |
| **프론트엔드 스택** | SwiftUI (iOS)              |

---

## AR 구현 메모

### 현재 사용 중인 Apple AR 스택

현재 GeoObject AR 테스트는 서드파티 SDK가 아니라 Apple 기본 AR 스택을 사용한다.

| 영역 | 사용 기술 | 역할 |
|------|-----------|------|
| 공간 추적 | ARKit `ARWorldTrackingConfiguration` | 카메라 위치, 회전, 월드 좌표 추적 |
| 렌더링 | RealityKit `ARView` | 카메라 화면 위에 3D 오브젝트 렌더링 |
| 오브젝트 | RealityKit `AnchorEntity`, `ModelEntity` | 월드 좌표에 빨간 큐브 배치 |
| 거리/방향 UI | RealityKit camera transform | 사용자 기준 큐브 방향과 거리 계산 |
| Depth occlusion | ARKit frame semantics + RealityKit people occlusion | 지원 기기에서 사람/손이 큐브를 가리는 효과 |

현재 진입 화면은 `AppNavigationView`의 `.splash` 분기에서 `GeoObjectARView()`를 띄운다.

### Depth occlusion 동작 방식

Depth occlusion은 실제 물체가 AR 오브젝트보다 카메라에 가까이 있을 때 AR 오브젝트를 가려 보이게 만드는 기능이다.

현재 코드는 아래 조건을 만족하는 기기에서만 depth 기반 사람 가림을 켠다.

```swift
if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
    configuration.frameSemantics.insert(.personSegmentationWithDepth)
    view.renderOptions.remove(.disablePersonOcclusion)
} else {
    view.renderOptions.insert(.disablePersonOcclusion)
}
```

핵심 기준은 기기 이름을 직접 비교하는 것이 아니라 `supportsFrameSemantics(.personSegmentationWithDepth)` 결과다. Apple도 frame semantics를 켜기 전에 `supportsFrameSemantics(_:)`로 지원 여부를 확인하라고 안내한다.

### 지원/미지원 기기 기준

정확한 최종 판단은 앱 실행 시점의 `supportsFrameSemantics(.personSegmentationWithDepth)` 결과를 따른다.

| 구분 | 기준 | 앱 동작 |
|------|------|---------|
| 지원 기기 | `personSegmentationWithDepth` 지원 | `Depth ON`, 사람/손이 큐브를 가릴 수 있음 |
| 미지원 기기 | `personSegmentationWithDepth` 미지원 | `Depth OFF`, 큐브는 손으로 가려도 그대로 보임 |

대표적으로 미지원으로 봐야 하는 기기:

- iPhone 8 / iPhone 8 Plus
- iPhone X
- A11 Bionic 이하 기기
- 후면 depth/segmentation 성능이 부족한 구형 iPad

대표적으로 지원 가능성이 높은 기기:

- A12 Bionic 이상 기기 중 `personSegmentationWithDepth`를 지원하는 모델
- LiDAR Scanner가 있는 iPhone Pro / Pro Max 계열
- LiDAR Scanner가 있는 iPad Pro 계열

LiDAR가 있는 기기는 scene depth 품질이 좋기 때문에 AR 내부 탐험, 실내 공간 occlusion, 거리 기반 배치에 더 적합하다. 단, 이 프로젝트의 현재 구현은 기기명을 하드코딩하지 않고 런타임 지원 여부만 본다.

### 3D 오브젝트 포맷 운영 기준

Android, Web, iOS에서 같은 3D 오브젝트를 각각 따로 제작/관리하지 않는다. 원본 관리는 `GLB` 하나로 통일하고, iOS 배포용 `USDZ`는 서버 파이프라인에서 자동 생성한다.

| 영역 | 포맷 | 책임 |
|------|------|------|
| 원본 관리 | `GLB` | 서버/관리툴에서 업로드, 버전 관리 |
| Web 배포 | `GLB` | Web 클라이언트가 직접 로드 |
| Android 배포 | `GLB` | Android 클라이언트가 직접 로드 |
| iOS 배포 | `USDZ` | 서버에서 `GLB`를 변환한 뒤 iOS 클라이언트가 로드 |

iOS 프론트엔드는 `GLB`를 직접 변환하지 않는다. iOS 앱은 서버가 내려주는 검수 완료 `usdz_url`만 다운로드하고, 로컬 캐시 후 RealityKit에서 로드한다.

권장 파이프라인:

```text
GLB 업로드
-> 서버가 GLB 저장
-> 서버가 USDZ 자동 변환
-> 관리자/작업자가 변환된 USDZ 품질 검수
-> 승인
-> iOS 앱은 승인된 USDZ만 다운로드
```

서버에서 변환해야 하는 이유:

- iOS 앱 용량과 런타임 부하를 줄일 수 있다.
- 사용자 기기에서 변환 실패가 발생하는 상황을 피할 수 있다.
- 변환된 `USDZ`의 텍스처, 머티리얼, 스케일, pivot, 애니메이션 상태를 배포 전에 사람이 검수할 수 있다.
- 기기 성능 차이와 변환 시간 문제를 앱에서 제거할 수 있다.

변환 후 검수해야 하는 항목:

- 모델 메시가 깨지지 않았는지
- 텍스처가 누락되지 않았는지
- 색감, roughness, metallic, alpha, emissive 등 머티리얼이 과하게 달라지지 않았는지
- scale, rotation, pivot이 맞는지
- 애니메이션이 있다면 정상 동작하는지
- 실제 iPhone AR 화면에서 성능 문제가 없는지

iOS 앱이 받을 모델 응답 예시:

```json
{
  "id": "building_001",
  "usdz_url": "https://cdn.nunulala.com/ar/building_001.usdz",
  "version": 3,
  "scale": 1.0,
  "latitude": 37.5547,
  "longitude": 126.9706,
  "altitude": 35.0,
  "yaw": 120.0
}
```

### 오디오 포맷 운영 기준

AR 오브젝트에 입체적인 음향을 붙일 때는 오디오 파일 자체가 입체감을 만드는 것이 아니라, 앱의 3D 오디오 엔진이 소리의 위치를 계산한다.

오디오는 Android, iOS, Web에서 공통으로 재생 가능한 `M4A(AAC-LC)`를 기본 배포 포맷으로 사용한다.

| 항목 | 기준 |
|------|------|
| 파일 확장자 | `.m4a` |
| 코덱 | `AAC-LC` |
| 샘플레이트 | `44.1kHz` 또는 `48kHz` |
| 비트레이트 | `128~192kbps` |
| 채널 | `mono` 또는 `stereo` |

플랫폼 호환성:

| 플랫폼 | `.m4a + AAC-LC` |
|--------|------------------|
| iOS | 지원 좋음 |
| Android | 지원 좋음 |
| Web | 대부분 지원 |

AR 위치 기반 음향은 보통 `mono m4a`가 더 적합하다. 앱이 사용자 위치와 방향을 기준으로 소리를 3D 공간에 배치하기 쉽기 때문이다.

오디오 운영 결론:

```text
3D 오브젝트 모델: iOS = USDZ, Android/Web = GLB
오디오: 공통 = M4A(AAC-LC)
```

서버 응답에서는 모델과 오디오를 분리해서 내려준다.

```json
{
  "id": "red_cube",
  "usdz_url": "https://cdn.nunulala.com/ar/red_cube.usdz",
  "glb_url": "https://cdn.nunulala.com/ar/red_cube.glb",
  "audio_url": "https://cdn.nunulala.com/ar/red_cube.m4a",
  "audio_channel": "mono",
  "audio_spatial": true
}
```

### 현재 제약

- iPhone 8급 기기에서는 `Depth OFF`가 정상이다.
- `Depth OFF` 상태에서는 손으로 큐브를 가릴 수 없다.
- `personSegmentationWithDepth`는 사람/손 중심의 occlusion이며, 책상/벽/물건 전체를 정확히 가리는 일반 scene depth와는 다르다.
- 손 가장자리는 흔들릴 수 있다.
- depth 기능은 성능 비용이 있으므로 지원 기기에서만 켠다.

### 참고 문서

- Apple Developer Documentation: `personSegmentationWithDepth`
  - https://developer.apple.com/documentation/arkit/arconfiguration/framesemantics-swift.struct/personsegmentationwithdepth
- Apple Developer Documentation: `supportsFrameSemantics(_:)`
  - https://developer.apple.com/documentation/arkit/arconfiguration/supportsframesemantics%28_%3A%29
- Apple Developer Documentation: ARKit configuration objects
  - https://developer.apple.com/documentation/arkit/configuration-objects

---

## 💡 스택 선정 이유

디자인이 완성되지 않은 상태였고 뷰 구조가 수시로 변경되는 상황이였습니다. 추가적으로 단기간에 구현해야하는 상태여서 UIKit보다는 SwiftUI를 채택하였습니다.

---

## 🔧 트러블슈팅 경험

| 문제 상황                                  | 해결 방법                                       |
|-------------------------------------------|------------------------------------------------|
| 1. 공공 데이터의 좌표 정보 부정확         | 마커 클러스터링 및 좌표 보정 로직 적용         |
| 2. OpenAPI 호출 시 SSL 및 인코딩 오류 발생 | 서비스키 인코딩 이슈 해결 + ATS 설정           |
| 3. 지도 마커 겹침                          | 좌표 소수점 단위 오프셋 적용 및 리스트뷰 연동 |
| 4. 외부 API 비용 문제                     | Google API 사용 최소화 → 대체 공공API 조합 시도 |

---

## 🛑 프로젝트 중단 배경 및 이후 진행

프로젝트는 **데이터 부족과 고비용 외부 API 문제**로 인해  
팀 단위 개발은 중단되었습니다.

Google Places API를 사용해야 했지만,  
추천 로직과 상세 정보 구현을 위해 필요한 API는  
**고비용 과금 구조로 인해 현실적인 제약**이 있었습니다.

이후, 저는 대체 데이터 소스를 찾아 **개인적으로 프로젝트를 인수**하여 마무리했습니다.

---

📌 개인적으로는 OpenAPI를 활용해 가능한 범위에서 다음을 구현했습니다:

- **카드매출 데이터 기반 추천 로직**
- **반경 내 근접 위치 기반 POI 검색**
- **관광API를 통한 이미지 제공**

하지만, 해당 공공데이터들의 **퀄리티와 양이 프로젝트의 요구 수준에 도달하지 못해**,  
기존 기획에 대한 방향 재정립이 필요했고, 그 한계를 체감하는 계기가 되었습니다.


### 📝 프로젝트 회고 – 환경에 졌던 순간, 그리고 다시 일어선 이유

> "사이드 프로젝트라도 높은 품질로 완성해 서비스를 배포해야한다" vs "사이드 프로젝트이니 품질이 다소 낮더라도 일단 배포해봐야 한다"

<기존안>
이번 프로젝트에서는 **"사이드 프로젝트라도 양질의 서비스로 완성해 배포해야 한다"**와 **"사이드 프로젝트이니 품질이 다소 낮더라도 일단 배포해봐야 한다"**라는 두 가치가 충돌하는 순간을 직접 경험했습니다.

프로젝트는 ‘양질의 서비스로 배포하자’는 방향으로 의견이 모였지만, 데이터 부족과 외부 API 비용 등 다양한 환경적 제약을 극복하지 못했습니다.
비슷한 난관이 반복되자 결국 협업이 중단되었고, 결과적으로 양질의 서비스도, 실제 배포도 이루어지지 못했습니다.

아직 방법을 찾지 못했을 뿐이라 생각했던 저는 끊임없이 대안을 모색했습니다.
조건이 나아지기만을 기다리는 대신, 혼자서 하나씩 문제를 해결해 나갔습니다.

유료 API 대신 Open API를 탐색하고, 호출 비용이 높은 별점·리뷰 기반 추천 대신 장소의 근접도와 카드 매출 데이터를 활용한 저비용 알고리즘을 설계했습니다.
이렇게 기존 접근 방식을 전환하며 프로젝트를 끝까지 완성했습니다.

이후 시장 매력을 재검토한 결과, 외국인을 대상으로 한국의 여행지와 문화를 소개하는 서비스로 피벗을 진행하고 있습니다.
이를 통해 저는 기술적 한계를 돌파하는 문제 해결력뿐 아니라, 서비스 방향을 유연하게 전환하는 실행력까지 경험할 수 있었습니다.


<개선예시>
이번 프로젝트에서는 **"사이드 프로젝트라도 양질의 서비스로 완성해 배포해야 한다"**와 **"사이드 프로젝트이니 품질이 다소 낮더라도 일단 배포해봐야 한다"**라는 가치가 충돌하는 순간을 경험했습니다.
결국 ‘양질의 서비스’ 방향으로 가닥을 잡았지만, 데이터 부족과 외부 API 비용 등 현실적인 제약에 부딪혀 협업이 중단되었습니다.

조건이 나아지기만을 기다리는 대신, 직접 문제를 하나씩 해결하기로 했습니다.
유료 API 대신 Open API를 조사·도입하고, 호출 비용이 높았던 기존의 별점·리뷰 기반 추천 알고리즘은 장소 근접도와 카드 매출 데이터 기반의 저비용 알고리즘으로 재설계했습니다.
또한, 사용자 후기 작성 기능을 적극적으로 활용하도록 유도해 내부 DB를 따로 구축하였습니다.

자체 서버를 구축하기엔 시간과 비용 부담이 컸기에, Firebase를 선택하여 서버 인프라 구축 없이 데이터 저장, 인증, 배포를 신속하게 구현했습니다.
이렇게 확보된 사용자 후기 데이터는 알고리즘 개선과 추천 정확도 향상에 직접 반영하였습니다.

이후 시장 매력을 재검토한 결과, 외국인을 대상으로 한국의 여행지와 문화를 소개하는 서비스로 피벗을 진행하고 있습니다.

(여기에 배포 이후에 성과가 나오면 성과 과정 작성)

이 경험을 통해 저는 환경 제약을 기술적 대안으로 극복하는 문제 해결력, 서비스 품질과 효율을 동시에 잡는 설계 능력, 그리고 데이터 기반으로 성과를 만들어내는 실행력을 함께 키울 수 있었습니다.
