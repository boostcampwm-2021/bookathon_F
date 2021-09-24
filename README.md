# Checkable : 부스트캠프 출석조회 어플 🗓

<center>
<br>
<br>
<img src="https://i.imgur.com/kMelGt3.png" width="650">
<br>
아직도 200여개의 댓글들을 스크롤하면서 불편하게 확인하시나요? 🥲
<br>
이제 앱에서 간단하게 출결사항을 조회하세요! 😆
</center>

## 💁🏻‍♀️ 팀원 & 역할 소개

|<img src="https://avatars.githubusercontent.com/u/43032377?v=4" width = 100>|<img src="https://i.imgur.com/V1KUwdf.jpg" width=100>|<img src="https://i.imgur.com/KD6hOp1.jpg" width=100>|
| :--------: | :--------: | :--------: |
|[S013] 김태훈<br>[@Modyhoon](https://github.com/Modyhoon)|[S036] 이나정<br>[@dailynj](https://github.com/dailynj)|[S045] 이지수<br> [@tmfrlrkvlek](https://github.com/tmfrlrkvlek)|
|크롤링 코드 작성|Firebase 세팅|크롤링 환경 세팅(EC2 & Crontab)|
|Firebase 데이터 수집|Firebase iOS 연동 & UI 작업|Firebase iOS 연동 & UI 작업|


<br>

## 📱 프로젝트 소개 

### 🥲 기존의 출첵시스템

| 매일 체크해야 하는 출결관리 | 일일히 확인해야하는 번거로움 |
| :--------------------: | :------------------:|
| <img src="https://i.imgur.com/glxiMHT.png" width=400>|<img src="https://user-images.githubusercontent.com/72058473/134460854-3ab0c0ca-505e-4d3e-9076-4ed5e4b0468c.gif" width=200>|

<br>

### ✔️ 서비스 핵심 기능

1. 부스트캠프 체크인, 체크아웃 기록 조회 (캘린더 형식)

    |출석부 예시 1|출석부 예시 2|
    |:----------:|:----------:|
    |![](https://i.imgur.com/UAe52nq.png)|![](https://i.imgur.com/jtwJbad.png)|
    

2. 출결 현황 확인
    |출결 현황 예시 1|출결 현황 예시 2|
    |:----------:|:----------:|
    |![](https://i.imgur.com/32yEhqM.png)|![](https://i.imgur.com/brgjHb1.png)|

3. 사용자의 아이디 저장 (with userDefaults)

<br>

### ⚒ 프로토타입
<img src="https://i.imgur.com/iM9oXlK.png" width=600>

<br>
<br>

### ✅ 시연 영상
<img src="https://user-images.githubusercontent.com/64150179/134621516-5c2955ba-8a04-4511-ba32-45370daa18fe.gif" width=300>

<br><br>

### 🏛  SW 아키텍처 & 사용 기술/라이브러리

<img src="https://i.imgur.com/pPbHg4e.png" width=650>

<br>

|서버|슬랙 스레드 크롤링([Link](https://api.slack.com/))|DB|APP|
|:-:|:-:|:-:|:-:|
|AWS EC2|Python|FireStore|iOS/Swift|
|Crontab|SlackAPI||FSCalendar|

<br>

### 🗂 DB Schema
<img src="https://i.imgur.com/rYAkP80.png" width=650>


<details><summary>자세히 보기</summary>
<p>

### Date

```json
// Date: 날짜
// CheckInOnly : 체크아웃 O - false, 체크아웃 X - true
// IsActive : Date Count 유무, True/False (19시에 True로 변환)

{
    Date: 2021-09-23,
    CheckInOnly: true,
    IsActive: false
}
```

</p>
            
<p>

### AttendanceDetail

```json
// Date : Date
// CamperId : CamperId
// CheckInTime :  10:00:01 | null
// CheckOutTime : 23:00:10 | null
// Attendance : True/False

{
    Date: 2021-09-23,
    CamperId: "S013",
    CheckInTime: 09:59:59,
    CheckOutTime: null,
    Attendence: true
}
```
    
</p>

<p>

### CamperId

```json
// CamperId : 번호
// Name : 이름
// Type : 안드로이드(K), iOS(S), 웹(J)

{
    CamperId: "S013",
    Name: "김태훈",
    Type: 'S'
}
```
</p>

<p>

### Attendance

```json
// CamperId : CamperId
// Count : 총 출석 횟수 

{
    CamperId: "S013",
    Count: 3
}
```

</p>

</details>

<br>

### 🏃‍♂️ Install & run
```bash=
git clone https://github.com/boostcampwm-2021/bookathon_F.git

cd BoostAttendance
pod init
pod install # m1 칩에서 오류가 발생한다면 arch -x86_64 pod install 을 실행해주세요
```

🧨  m1 칩에서 pod install 오류가 난다면 -> ```arch -x86_64 pod install``` 을 실행해주세요

🧨  Firebase 오류가 난다면 -> [링크](https://gogorchg.tistory.com/entry/iOS-Error-Could-not-build-ObjectiveC-module-Firebase)

🧨 CocoaPod 오류가 난다면 -> [링크](https://escnet.tistory.com/24)

<br>

## 🥕 개발 후기
### 파이어베이스 기본 용량 초과 😮
  체크인 - 체크아웃 스레드의 댓글이 각 200여개에 이름
  
  <img src="https://i.imgur.com/CtX7t2j.png" width="400">
  
  중복체크 로직 등 DB에 접근하는 쿼리의 양이 점점 많아지고, 
  
  결국 사용량 초과로 무료 요금제는 더 이상 사용하지 못하게 됨 😭
  
  눈물을 머금고 새벽3시에 **Blaze 요금제 결제 💸💸💸**
  
  <img src="https://i.imgur.com/f9GZ7QO.png" width="450">
  
  약 **31만회**의 읽기 트래픽
  
  <img src="https://i.imgur.com/x7QHHSe.png" width="800">
  
<br>

### XCode 버전이 달라서 열지 못하는 이슈 😩
  XCode 최신버전인 **13.0** 환경에서 프로젝트 생성
  
  해당 프로젝트를 XCode 12.6 환경에서 실행하니 다음과 같이 이슈 발생
  
  <img src="https://i.imgur.com/lGpDmW8.png" width="500">
  
  <br>
  
  이후 계속해서 원인을 찾아보다가 XCode를 업그레이드 (13.0) 하니 정상적으로 프로젝트가 열림.
  
  협업을 할때에는 개발 환경을 먼저 맞추고 시작하는게 중요하다는 것을 다시금 느낀 경험

