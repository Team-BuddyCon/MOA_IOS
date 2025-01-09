//
//  String+.swift
//  MOA
//
//  Created by 오원석 on 10/1/24.
//

import Foundation

// MARK: Common
let LETS_START = "시작하기"
let CANCEL = "취소하기"
let SAVE = "저장하기"
let EXPIRE_DATE = "유효기간"
let STORE = "사용처"
let OTHER_STORE = "기타"
let EDIT = "편집"
let COMPLETE = "완료"
let DELETE = "삭제"
let CLOSE = "닫기"
let DELETE_MODAL = "삭제하기"
let UPDATE_MODAL = "수정하기"
let CONFIRM = "확인"

// MARK: Design System
let dday_end = "만료"
let dday_format = "D-%d"
let dday_over365 = "D-365+"

// MARK: WalkThrough
let WALKTHROUGH_SKIP = "건너뛰기"
let WALKTHROUGH_NEXT = "다음"
let WALKTHROUGH_BANNER1_IMGRES = "WalkThroughBanner1"
let WALKTHROUGH_BANNER1_TITLE = "기프티콘을 한곳에서 관리해요"
let WALKTHROUGH_BANNER1_DESCRIPTION = "흩어져 있는 기프티콘을 한곳에서 확인하고\n만료 전 알림으로 유효기간을 관리해요"
let WALKTHROUGH_BANNER2_IMGRES = "WalkThroughBanner2"
let WALKTHROUGH_BANNER2_TITLE = "사용처를 한눈에 확인해요"
let WALKTHROUGH_BANNER2_DESCRIPTION = "지도를 통해 근처에서 기프티콘\n사용 가능한 매장을 확인해요"

// MARK: Login
let LOGIN_ICON = "LoginIcon"
let KAKAO_LOGIN_BUTTON_IMAGES = "KakaoLoginButton"

// MARK: SignUp
let SIGNUP_TITLE = "회원가입"
let SIGNUP_TERMS_GUIDE_TITLE = "모아의 서비스\n이용약관에 동의해주세요"
let SIGNUP_AGREE_TO_ALL = "전체 동의하기"
let SIGNUP_MOA_TERMS_OF_USE_TITLE = "모아 이용약관"
let SIGNUP_PRIVACY_POLICY_TITLE = "개인정보 처리방침"
let SIGNUP_AGREE_TO_TERMS_OF_USE = "[필수] 이용약관 동의"
let SIGNUP_AGREE_TO_PRIVACY_POLICY = "[필수] 개인정보 처리방침 동의"
let SIGNUP_COMPLETE = "회원가입 완료"
let SIGNUP_COMPLETE_TITLE = "회원가입 완료!"
let SIGNUP_COMPLETE_SUBTITLE_FORMAT = "MOA의 소중한 회원이 되신 %@님,\n만나서 반가워요!"
let SIGNUP_SERVICE_TERMS_URL = "https://scarce-cartoon-27d.notion.site/e09da35361e142b7936c12e38396475e"
let SIGNUP_PRIVACY_INFORMATION_URL = "https://scarce-cartoon-27d.notion.site/c4e5ff54f9bd434e971a2631d122252c"

// MARK: Home
let GIFTICON_MENU_TITLE = "기프티콘"
let MAP_MENU_TITLE = "지도"
let MYPAGE_MENU_TITLE = "마이페이지"

// MARK: Gifticon
let GIFTICON_EMPTY_TITLE = "아래 플러스 버튼을 눌러\n가지고 있는 기프티콘을 등록해 주세요"
let GIFTICON_IMAGE_PERMISSION_TITLE = "저장을 위해 접근 권한이 필요해요"
let GIFTICON_IMAGE_PERMISSION_SUBTITLE = "기프티콘 이미지를 저장하기 위해\n외부 저장소 접근을 허용해 주세요."
let GIFTICON_IMAGE_PERMISSION_ALLOW = "허용하기"
let GIFTICON_REGISTER_TITLE = "기프티콘 등록하기"
let GIFTICON_REGSITER_NAME_INPUT_TITLE = "기프티콘 이름"
let GIFTICON_REGISTER_NAME_INPUT_HINT = "최대 16자"
let GIFTICON_REGISTER_EXPIRE_DATE_INPUT_TITLE = "유효기간"
let GIFTICON_REGISTER_EXPIRE_DATE_INPUT_HINT = "유효기간 선택"
let GIFTICON_REGISTER_STORE_INPUT_TITLE = "사용처"
let GIFTICON_REGISTER_STORE_INPUT_HINT = "사용처 선택"
let GIFTICON_REGISTER_MEMO_INPUT_TITLE = "메모"
let GIFTICON_REGISTER_MEMO_INPUT_HINT = "최대 50자"
let GIFTICON_REGISTER_OTHER_STORE_GUIDE = "기프티콘 사용처를 입력해주세요"
let GIFTICON_REGISTER_OTHER_STORE_INFO = "앞으로 더 많은 브랜드를 지원하기 위해서 노력할게요."
let GIFTICON_REGISTER_OTHER_STORE_PLACEHOLDER = "예) 롯데리아"
let GIFTICON_REGISTER_OTHER_STORE_PREVIOUS_BUTTON = "이전으로"
let GIFTICON_REGISTER_OTHER_STORE_COMPLETED = "작성완료"
let GIFTICON_REGISTER_TOAST_MESSAGE = "기프티콘 정보를 등록해 주세요"
let GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_TITLE = "기프티콘을 등록하지 못했어요"
let GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_SUBTITLE = "바코드가 잘리거나 손상되지 않았는지\n확인 후에 다시 시도해 주세요."
let GIFTICON_REGISTER_MAX_LENGTH_MODAL_TITLE = "최대 글자 수를 초과했어요"
let GIFTICON_REGISTER_MAX_LENGTH_NAME_MODAL_SUBTITLE = "기프티콘 이름은 최대 16자로 입력할 수 있어요."
let GIFTICON_REGISTER_EMPTY_NAME_MODAL_TITLE = "기프티콘 이름을 입력해 주세요"
let GIFTICON_REGISTER_EMPTY_EXPIRE_DATE_MODAL_TITLE = "유효기간을 선택해 주세요"
let GIFTICON_REGISTER_EMPTY_STORE_MODAL_TITLE = "사용처를 선택해 주세요"
let GIFTICON_REGISTER_MAX_LENGTH_MEMO_MODAL_SUBTITLE = "메모는 최대 50자로 입력할 수 있어요."
let GIFTICON_REGISTER_STOP_TITLE = "기프티콘 등록을 그만할까요?"
let GIFTICON_REGISTER_STOP_CONFIRM_TEXT = "그만하기"
let GIFTICON_REGISTER_STOP_CONTINUE_TEXT = "계속하기"
let GIFTICON_REGISTER_EXPIRE_MODAL_TITLE = "유효기간이 지난 기프티콘이에요"
let GIFTICON_REGISTER_EXPIRE_MODAL_SUBTITLE = "아래의 사용완료 버튼을 눌러주세요."
let GIFTICON_DETAIL_EXPIRE_DATE_TITLE = "유효기간"
let GIFTICON_DETAIL_STORE_TITLE = "사용처"
let GIFTICON_DETAIL_MEMO_TITLE = "메모"
let GIFTICON_DETAIL_MAP_ZOOM_IN_BUTTON_TITLE = "지도 확대하기"
let GIFTICON_DETAIL_MAP_CONFIRM_BUTTON_TITLE = "확인했어요"
let GIFTICON_USE_BUTTON_TITLE = "사용완료"
let GIFTICON_USED_BUTTON_TITLE = "사용완료 되돌리기"
let GIFTICON_DELETE_MODAL_TITLE = "기프티콘을 삭제할까요?"
let GIFTICON_DELETE_SUCCESS_MODAL_TITLE = "기프티콘이 삭제되었어요"
let GIFTICON_DELETE_NAVIGATION_HOME_MODAL_TITLE = "홈으로 이동"
let GIFTICON_UPDATE_MODAL_TITLE = "기프티콘을 수정할까요?"
let GIFTICON_UPDATE_SUCCESS_MODAL_TITLE = "기프티콘이 수정되었어요"

// MARK: Mypage
let MYPAGE_UNAVAILABLE_GIFTICON = "사용한 기프티콘"

// MARK: ImageSet
let BACK_BUTTON_IMAGE_ASSET = "BackButton"
let CHECK_BUTTON_IMAGE_ASSET = "CheckButton"
let FORWARD_BUTTON_IMAGE_ASSET = "ForwardButton"
let SIGNUP_COMPLETE_ICON_ASSET = "SignUpCompleteIcon"
let GIFTICON_MENU = "GifticonMenu"
let GIFTICON_SELECTED_MENU = "GifticonSelMenu"
let MAP_MENU = "MapMenu"
let MAP_SELECTED_MENU = "MapSelMenu"
let MYPAGE_MENU = "MypageMenu"
let MYPAGE_SELECTED_MENU = "MypageSelMenu"
let DOWN_ARROW = "DownArrow"
let FLOATING_ICON = "FloatingIcon"
let EMPTY_GIFTICON = "EmptyGifticon"
let EXPIRE_DATE_INPUT_ICON = "ExpireDateInputIcon"
let STORE_INPUT_ICON = "StoreInputIcon"
let CLOSE_BUTTON = "CloseButton"
let STARBUCKS_IMAGE = "StarBucks"
let TWOSOME_PLACE_IMAGE = "TwoSomePlace"
let ANGELINUS_IMAGE = "Angelinus"
let MEGA_COFFEE_IMAGE = "MegaCoffee"
let COFFEE_BEAN_IMAGE = "CoffeeBean"
let GONG_CHA_IMAGE = "GongCha"
let BASKIN_ROBBINS_IMAGE = "BaskinRobbins"
let MACDONALD_IMAGE = "Macdonald"
let GS25_IMAGE = "GS25"
let CU_IMAGE = "CU"
let OTHERS_IMAGE = "Others"
let ZOOM_IN_BUTTON = "ZoomInButton"
let DELETE_BUTTON = "DeleteButton"
let USED_GIFTICON = "UsedGifticon"
let CAFE_POI_ICON = "CafePoiIcon"
let FAST_FOOD_POI_ICON = "FastFoodPoiIcon"
let STORE_POI_ICON = "StorePoiIcon"
let UNAVAILABLE_GIFTICON = "UnavailableGifticon"
let NOTIFICATION_ICON = "NotificationIcon"

// MARK: Font
let pretendard_black = "Pretendard-Black"
let pretendard_bold = "Pretendard-Bold"
let pretendard_extrabold = "Pretendard-ExtraBold"
let pretendard_extraLight = "Pretendard-ExtraLight"
let pretendard_light = "Pretendard-Light"
let pretendard_medium = "Pretendard-Medium"
let pretendard_regular = "Pretendard-Regular"
let pretendard_semibold = "Pretendard-SemiBold"
let pretendard_thin = "Pretendard-Thin"
