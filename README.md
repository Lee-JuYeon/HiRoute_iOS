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

이번 프로젝트에서는 **"사이드 프로젝트라도 양질의 서비스로 완성해 배포해야 한다"**와 **"사이드 프로젝트이니 품질이 다소 낮더라도 일단 배포해봐야 한다"**라는 두 가치가 충돌하는 순간을 직접 경험했습니다.

프로젝트는 '양질의 서비스로 배포하자'는 방향으로 의견이 모였지만, 데이터 부족과 외부 API 비용 등 다양한 환경적 제약을 극복하지 못했습니다.
비슷한 난관이 반복되자 결국 협업이 중단되었고, 결과적으로 양질의 서비스도, 실제 배포도 이루어지지 못했습니다.

아직 방법을 찾지 못했을 뿐이라 생각했던 저는 끊임없이 대안을 모색했습니다.
조건이 나아지기만을 기다리는 대신, 혼자서 하나씩 문제를 해결해 나갔습니다.

유료 API 대신 Open API를 탐색하고, 호출 비용이 높은 별점·리뷰 기반 추천 대신 장소의 근접도와 카드 매출 데이터를 활용한 저비용 알고리즘을 설계했습니다.
이렇게 기존 접근 방식을 전환하며 프로젝트를 끝까지 완성했습니다.

이후 시장 매력을 재검토한 결과, 외국인을 대상으로 한국의 여행지와 문화를 소개하는 서비스로 피벗을 진행하고 있습니다.
이를 통해 저는 기술적 한계를 돌파하는 문제 해결력뿐 아니라, 서비스 방향을 유연하게 전환하는 실행력까지 경험할 수 있었습니다.
