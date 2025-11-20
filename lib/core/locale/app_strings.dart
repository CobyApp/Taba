import 'package:flutter/material.dart';
import 'package:taba_app/core/locale/app_locale.dart';

/// 앱의 모든 문자열을 로컬라이즈하는 클래스
class AppStrings {
  AppStrings._();
  
  static String getString(BuildContext context, String Function(Locale) getter) {
    final locale = AppLocaleController.localeNotifier.value;
    return getter(locale);
  }

  // 앱 이름
  static String get appName => 'Taba';

  // 메인 화면
  static String mainScreenEmptyTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'No seeds yet';
      case 'ja':
        return 'まだ種がありません';
      default:
        return '아직 씨앗이 없어요';
    }
  }

  static String mainScreenEmptySubtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Write your first letter';
      case 'ja':
        return '最初の手紙を書いてみてください';
      default:
        return '첫 번째 편지를 작성해보세요';
    }
  }

  static String refreshButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Refresh';
      case 'ja':
        return '更新';
      default:
        return '새로고침';
    }
  }

  static String myBouquetTooltip(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'My Bouquet';
      case 'ja':
        return '私の花束';
      default:
        return '내 꽃다발';
    }
  }

  static String settingsTooltip(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Settings';
      case 'ja':
        return '設定';
      default:
        return '설정';
    }
  }

  // 설정 화면
  static String settingsTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Settings';
      case 'ja':
        return '設定';
      default:
        return '설정';
    }
  }

  static String notificationsSection(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Notifications';
      case 'ja':
        return '通知';
      default:
        return '알림';
    }
  }

  static String notificationUpdateFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to update notification settings';
      case 'ja':
        return '通知設定の変更に失敗しました';
      default:
        return '알림 설정 변경에 실패했습니다';
    }
  }

  static String pushNotifications(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Push Notifications';
      case 'ja':
        return 'プッシュ通知';
      default:
        return '푸시 알림';
    }
  }

  static String pushNotificationsSubtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Get notified about new letters and reactions';
      case 'ja':
        return '新しい手紙や反応について通知を受け取ります';
      default:
        return '새 편지와 반응을 알려드릴게요';
    }
  }

  static String notificationPermissionDenied(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Notification permission denied';
      case 'ja':
        return '通知の許可が拒否されました';
      default:
        return '알림 권한이 거부되었습니다';
    }
  }

  static String openSystemSettings(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Open System Settings';
      case 'ja':
        return 'システム設定を開く';
      default:
        return '시스템 설정 열기';
    }
  }

  static String notificationPermissionDeniedMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enable notifications in system settings to receive push notifications.';
      case 'ja':
        return 'プッシュ通知を受信するには、システム設定で通知を有効にしてください。';
      default:
        return '푸시 알림을 받으려면 시스템 설정에서 알림을 허용해주세요.';
    }
  }

  static String friendInviteSection(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Friend Invite';
      case 'ja':
        return '友達招待';
      default:
        return '친구 초대';
    }
  }

  static String inviteCodeLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please generate a code';
      case 'ja':
        return 'コードを発行してください';
      default:
        return '코드를 발급해주세요';
    }
  }

  static String validTime(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Valid for';
      case 'ja':
        return '有効期限';
      default:
        return '유효 시간';
    }
  }

  static String expired(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Expired · Regeneration required';
      case 'ja':
        return '期限切れ・再発行が必要です';
      default:
        return '만료됨 · 재발급이 필요해요';
    }
  }

  static String copyButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Copy';
      case 'ja':
        return 'コピー';
      default:
        return '복사';
    }
  }

  static String shareButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Share';
      case 'ja':
        return '共有';
      default:
        return '공유';
    }
  }

  static String generateButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Generate';
      case 'ja':
        return '発行';
      default:
        return '발급';
    }
  }

  static String regenerateButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Regenerate';
      case 'ja':
        return '再発行';
      default:
        return '재발급';
    }
  }

  static String addFriendByCode(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Add by Friend Code';
      case 'ja':
        return '友達コードで追加';
      default:
        return '친구 코드로 추가';
    }
  }

  static String addFriendByCodeButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Add by Friend Code';
      case 'ja':
        return '友達コードで追加';
      default:
        return '친구 코드로 추가';
    }
  }

  static String accountSection(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Account';
      case 'ja':
        return 'アカウント';
      default:
        return '계정';
    }
  }

  static String changePassword(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Change Password';
      case 'ja':
        return 'パスワード変更';
      default:
        return '비밀번호 변경';
    }
  }

  static String deleteAccount(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Delete Account';
      case 'ja':
        return 'アカウント削除';
      default:
        return '회원탈퇴';
    }
  }

  static String deleteAccountConfirm(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Are you sure you want to delete your account? This action cannot be undone.';
      case 'ja':
        return 'アカウントを削除してもよろしいですか？この操作は取り消せません。';
      default:
        return '정말 회원탈퇴를 하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
    }
  }

  static String accountDeleted(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Account deleted';
      case 'ja':
        return 'アカウントが削除されました';
      default:
        return '회원탈퇴가 완료되었습니다';
    }
  }

  static String accountDeletedMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Your account has been successfully deleted.';
      case 'ja':
        return 'アカウントが正常に削除されました。';
      default:
        return '회원 탈퇴가 완료되었습니다.';
    }
  }

  static String deleteAccountFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to delete account';
      case 'ja':
        return 'アカウント削除に失敗しました';
      default:
        return '회원탈퇴에 실패했습니다';
    }
  }

  static String languageSection(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Language';
      case 'ja':
        return '言語';
      default:
        return '언어';
    }
  }

  static String appLanguage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'App Language';
      case 'ja':
        return 'アプリ言語';
      default:
        return '앱 언어';
    }
  }

  static String privacySettings(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Privacy Settings';
      case 'ja':
        return 'プライバシー設定';
      default:
        return '개인정보 설정';
    }
  }

  static String logout(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Logout';
      case 'ja':
        return 'ログアウト';
      default:
        return '로그아웃';
    }
  }

  // 꽃다발 화면
  static String bouquetTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Bouquet';
      case 'ja':
        return '花束';
      default:
        return '꽃다발';
    }
  }

  static String sendLetterToFriend(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Send Letter to This Friend';
      case 'ja':
        return 'この友達に手紙を送る';
      default:
        return '이 친구에게 편지 보내기';
    }
  }

  static String noBouquetYet(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'No bouquet yet';
      case 'ja':
        return 'まだ花束がありません';
      default:
        return '아직 꽃다발이 없어요';
    }
  }

  static String noBouquetSubtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Bouquets appear when you exchange letters with friends';
      case 'ja':
        return '友達と手紙を交換すると花束が現れます';
      default:
        return '친구와 편지를 주고받으면 꽃다발이 생겨요';
    }
  }

  // 로그인 화면
  static String loginTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Taba';
      case 'ja':
        return 'Taba';
      default:
        return 'Taba';
    }
  }

  static String loginSubtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Catch floating seeds and bloom flowers';
      case 'ja':
        return '浮かぶ種を捕まえて花を咲かせましょう';
      default:
        return '떠다니는 씨앗을 잡아 꽃을 피워보세요';
    }
  }

  static String email(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Email';
      case 'ja':
        return 'メール';
      default:
        return '이메일';
    }
  }

  static String password(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Password';
      case 'ja':
        return 'パスワード';
      default:
        return '비밀번호';
    }
  }

  static String loginButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Login';
      case 'ja':
        return 'ログイン';
      default:
        return '로그인';
    }
  }

  static String signupLink(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return "Don't have an account? Sign up";
      case 'ja':
        return 'アカウントをお持ちでないですか？登録する';
      default:
        return '계정이 없으신가요? 회원가입';
    }
  }

  static String forgotPassword(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Forgot Password?';
      case 'ja':
        return 'パスワードをお忘れですか？';
      default:
        return '비밀번호를 잊으셨나요?';
    }
  }

  // 회원가입 화면
  static String signupTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign Up';
      case 'ja':
        return '登録';
      default:
        return '회원가입';
    }
  }

  static String signupSubtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign up with email';
      case 'ja':
        return 'メールで登録';
      default:
        return '이메일로 가입하세요';
    }
  }

  static String nickname(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Nickname';
      case 'ja':
        return 'ニックネーム';
      default:
        return '닉네임';
    }
  }

  static String confirmPassword(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Confirm Password';
      case 'ja':
        return 'パスワード確認';
      default:
        return '비밀번호 확인';
    }
  }

  static String currentPassword(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Current Password';
      case 'ja':
        return '現在のパスワード';
      default:
        return '현재 비밀번호';
    }
  }

  static String newPassword(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'New Password';
      case 'ja':
        return '新しいパスワード';
      default:
        return '새 비밀번호';
    }
  }

  static String currentPasswordRequired(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter your current password';
      case 'ja':
        return '現在のパスワードを入力してください';
      default:
        return '현재 비밀번호를 입력해주세요';
    }
  }

  static String newPasswordRequired(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter a new password';
      case 'ja':
        return '新しいパスワードを入力してください';
      default:
        return '새 비밀번호를 입력해주세요';
    }
  }

  static String passwordMinLength(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Password must be at least 8 characters';
      case 'ja':
        return 'パスワードは8文字以上である必要があります';
      default:
        return '비밀번호는 최소 8자 이상이어야 합니다';
    }
  }

  static String passwordChanged(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Password Changed';
      case 'ja':
        return 'パスワードが変更されました';
      default:
        return '비밀번호가 변경되었습니다';
    }
  }

  static String passwordChangedMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Your password has been successfully changed.';
      case 'ja':
        return 'パスワードが正常に変更されました。';
      default:
        return '비밀번호가 성공적으로 변경되었습니다.';
    }
  }

  static String passwordChangeFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to change password. Please try again.';
      case 'ja':
        return 'パスワードの変更に失敗しました。もう一度お試しください。';
      default:
        return '비밀번호 변경에 실패했습니다. 다시 시도해주세요.';
    }
  }

  static String change(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Change';
      case 'ja':
        return '変更';
      default:
        return '변경';
    }
  }

  static String agreeTerms(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'I agree to the Terms of Service';
      case 'ja':
        return '利用規約に同意します';
      default:
        return '이용약관에 동의합니다';
    }
  }

  static String agreePrivacy(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'I agree to the Privacy Policy';
      case 'ja':
        return 'プライバシーポリシーに同意します';
      default:
        return '개인정보처리방침에 동의합니다';
    }
  }

  static String signupButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign Up';
      case 'ja':
        return '登録';
      default:
        return '회원가입';
    }
  }

  static String alreadyHaveAccount(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Already have an account? Login';
      case 'ja':
        return 'すでにアカウントをお持ちですか？ログイン';
      default:
        return '이미 계정이 있으신가요? 로그인';
    }
  }

  // 비밀번호 찾기 화면
  static String forgotPasswordSubtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Enter your registered email address and we will send you a reset link';
      case 'ja':
        return '登録済みのメールアドレスを入力すると、リセットリンクを送信します';
      default:
        return '가입한 이메일 주소를 입력하면 재설정 링크를 보내드려요.';
    }
  }

  static String sendResetLink(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Send Reset Link';
      case 'ja':
        return 'リセットリンクを送信';
      default:
        return '재설정 링크 보내기';
    }
  }

  // 약관 화면
  static String termsTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Terms / Privacy';
      case 'ja':
        return '利用規約 / プライバシー';
      default:
        return '이용약관 / 개인정보';
    }
  }

  // 편지 상세 화면
  static String replyButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Reply';
      case 'ja':
        return '返信';
      default:
        return '답장하기';
    }
  }

  static String reportButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Report';
      case 'ja':
        return '報告';
      default:
        return '신고';
    }
  }

  static String anonymousUser(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Anonymous User';
      case 'ja':
        return '匿名ユーザー';
      default:
        return '익명의 사용자';
    }
  }

  // 편지 쓰기 화면
  static String attachPhoto(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Attach Photo';
      case 'ja':
        return '写真を添付';
      default:
        return '사진 첨부';
    }
  }

  static String template(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Template';
      case 'ja':
        return 'テンプレート';
      default:
        return '템플릿';
    }
  }

  static String font(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Font';
      case 'ja':
        return 'フォント';
      default:
        return '폰트';
    }
  }

  // 씨앗 꽃 피우기
  static String bloomSeedQuestion(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Bloom the seed?';
      case 'ja':
        return '種を咲かせますか？';
      default:
        return '씨앗을 꽃피워볼까요?';
    }
  }

  static String bloomSeedSubtitle(Locale locale, String flowerName) {
    switch (locale.languageCode) {
      case 'en':
        return 'When $flowerName blooms, you can read the letter.';
      case 'ja':
        return '$flowerNameが咲いたら、手紙を読むことができます。';
      default:
        return '$flowerName이 피어나면 편지를 볼 수 있어요.';
    }
  }

  static String bloomButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Bloom';
      case 'ja':
        return '咲かせる';
      default:
        return '꽃 피우기';
    }
  }

  static String blooming(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Blooming...';
      case 'ja':
        return '咲いている...';
      default:
        return '꽃 피우는 중...';
    }
  }

  // 씨앗 열기 메시지 (감성적인 멘트)
  static List<String> bloomSeedMessages(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return [
          'A letter is waiting inside this seed',
          'Someone left you a message',
          'Open your heart and read',
          'A gentle whisper awaits you',
          'Words bloom like flowers',
          'Someone thought of you',
          'A moment of connection',
          'Feel the warmth within',
          'A story wants to be told',
          'Love grows from small seeds',
        ];
      case 'ja':
        return [
          'この種の中に手紙が待っています',
          '誰かがあなたにメッセージを残しました',
          '心を開いて読んでください',
          '優しいささやきがあなたを待っています',
          '言葉は花のように咲きます',
          '誰かがあなたのことを考えていました',
          'つながりの瞬間',
          '中の温かさを感じてください',
          '物語が語られたいと思っています',
          '愛は小さな種から育ちます',
        ];
      default:
        return [
          '이 씨앗 안에 편지가 기다리고 있어요',
          '누군가 당신에게 메시지를 남겼어요',
          '마음을 열고 읽어보세요',
          '따뜻한 이야기가 기다리고 있어요',
          '작은 씨앗에서 피어나는 마음',
          '누군가 당신을 생각했어요',
          '마음을 전하는 순간',
          '씨앗 속에 담긴 따뜻함',
          '전하고 싶은 이야기가 있어요',
          '작은 씨앗에서 자라나는 마음',
        ];
    }
  }


  static String emailHint(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'neon@taba.app';
      case 'ja':
        return 'neon@taba.app';
      default:
        return 'neon@taba.app';
    }
  }

  static String passwordHint(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '••••••••';
      case 'ja':
        return '••••••••';
      default:
        return '••••••••';
    }
  }

  static String loginWithEmail(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Login with Email';
      case 'ja':
        return 'メールでログイン';
      default:
        return '이메일로 로그인';
    }
  }

  static String findPassword(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Find Password';
      case 'ja':
        return 'パスワードを探す';
      default:
        return '비밀번호 찾기';
    }
  }

  static String signupWithEmail(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign Up with Email';
      case 'ja':
        return 'メールで登録';
      default:
        return '이메일 가입';
    }
  }

  static String emailPasswordRequired(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter email and password';
      case 'ja':
        return 'メールアドレスとパスワードを入力してください';
      default:
        return '이메일과 비밀번호를 입력해주세요';
    }
  }

  static String loginFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Login failed. Please try again.';
      case 'ja':
        return 'ログインに失敗しました。もう一度お試しください。';
      default:
        return '로그인에 실패했습니다. 다시 시도해주세요.';
    }
  }

  static String errorOccurred(Locale locale, String error) {
    switch (locale.languageCode) {
      case 'en':
        return 'An error occurred: $error';
      case 'ja':
        return 'エラーが発生しました: $error';
      default:
        return '오류가 발생했습니다: $error';
    }
  }

  // 회원가입 화면
  static String selectFromGallery(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Select from Gallery';
      case 'ja':
        return 'ギャラリーから選択';
      default:
        return '갤러리에서 선택';
    }
  }

  static String takePhoto(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Take Photo';
      case 'ja':
        return '写真を撮る';
      default:
        return '카메라로 촬영';
    }
  }

  static String removePhoto(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Remove Photo';
      case 'ja':
        return '写真を削除';
      default:
        return '사진 제거';
    }
  }

  static String photoError(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'An error occurred while taking/selecting photo: ';
      case 'ja':
        return '写真の撮影/選択中にエラーが発生しました: ';
      default:
        return '사진 촬영 중 오류가 발생했습니다: ';
    }
  }

  static String profileUpdated(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Profile updated';
      case 'ja':
        return 'プロフィールが更新されました';
      default:
        return '프로필이 수정되었어요';
    }
  }

  static String changesSaved(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Changes have been saved.';
      case 'ja':
        return '変更が保存されました。';
      default:
        return '변경사항이 저장되었습니다.';
    }
  }

  static String nicknameRequired(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter a nickname';
      case 'ja':
        return 'ニックネームを入力してください';
      default:
        return '닉네임을 입력해주세요';
    }
  }

  static String allFieldsRequired(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please fill in all fields';
      case 'ja':
        return 'すべてのフィールドを入力してください';
      default:
        return '모든 필드를 입력해주세요';
    }
  }

  static String passwordMismatch(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Passwords do not match';
      case 'ja':
        return 'パスワードが一致しません';
      default:
        return '비밀번호가 일치하지 않습니다';
    }
  }

  static String agreeTermsRequired(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please agree to the Terms of Service and Privacy Policy';
      case 'ja':
        return '利用規約とプライバシーポリシーに同意してください';
      default:
        return '이용약관과 개인정보처리방침에 동의해주세요';
    }
  }

  static String signupFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign up failed. Please try again.';
      case 'ja':
        return '登録に失敗しました。もう一度お試しください。';
      default:
        return '회원가입에 실패했습니다. 다시 시도해주세요.';
    }
  }

  // 설정 화면 추가
  static String inviteCodeCopied(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Invite code copied';
      case 'ja':
        return '招待コードがコピーされました';
      default:
        return '초대 코드가 복사되었어요';
    }
  }

  static String inviteCodeCopiedMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Share the code with your friends to fill the sky together.';
      case 'ja':
        return 'コードを友達と共有して、一緒に空を埋めましょう。';
      default:
        return '친구에게 코드를 공유해 함께 하늘을 채워보세요.';
    }
  }

  static String shareInviteMessage(Locale locale, String code) {
    switch (locale.languageCode) {
      case 'en':
        return 'Friend Code: $code\nAdd friends with this code in the Taba app!';
      case 'ja':
        return '友達コード: $code\nTabaアプリでこのコードで友達を追加してください！';
      default:
        return '친구 코드: $code\nTaba 앱에서 이 코드로 친구를 추가해보세요!';
    }
  }

  static String addFriend(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Add Friend';
      case 'ja':
        return '友達を追加';
      default:
        return '친구 추가';
    }
  }

  static String friendCode(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Friend Code';
      case 'ja':
        return '友達コード';
      default:
        return '친구 코드';
    }
  }

  static String friendCodeHint(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'e.g., user123-456789';
      case 'ja':
        return '例: user123-456789';
      default:
        return '예: user123-456789';
    }
  }

  static String cancel(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Cancel';
      case 'ja':
        return 'キャンセル';
      default:
        return '취소';
    }
  }

  static String add(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Add';
      case 'ja':
        return '追加';
      default:
        return '추가';
    }
  }

  static String addFriendFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to add friend. Please check the code.';
      case 'ja':
        return '友達の追加に失敗しました。コードを確認してください。';
      default:
        return '친구 추가에 실패했습니다. 코드를 확인해주세요.';
    }
  }

  static String inviteCodeGenerationFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to generate invite code';
      case 'ja':
        return '招待コードの生成に失敗しました';
      default:
        return '초대 코드 생성에 실패했습니다';
    }
  }

  static String enterFriendCode(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter a friend code';
      case 'ja':
        return '友達コードを入力してください';
      default:
        return '친구 코드를 입력해주세요';
    }
  }

  static String friendAdded(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Friend added';
      case 'ja':
        return '友達が追加されました';
      default:
        return '친구가 추가되었어요';
    }
  }

  static String friendAddedMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'You can now exchange letters with each other.';
      case 'ja':
        return 'これでお互いの手紙をやり取りできます。';
      default:
        return '이제 서로의 편지를 주고받을 수 있어요.';
    }
  }

  static String cannotAddSelf(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Cannot add yourself';
      case 'ja':
        return '自分を追加できません';
      default:
        return '본인은 친구 추가할 수 없습니다';
    }
  }

  static String cannotAddSelfMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'You cannot add yourself as a friend.';
      case 'ja':
        return '自分を友達として追加することはできません。';
      default:
        return '자신의 초대 코드로는 친구를 추가할 수 없습니다.';
    }
  }

  static String alreadyFriends(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Already friends';
      case 'ja':
        return 'すでに友達です';
      default:
        return '이미 친구입니다';
    }
  }

  static String alreadyFriendsMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'You are already friends with this user.';
      case 'ja':
        return 'このユーザーとはすでに友達です。';
      default:
        return '이미 친구 관계입니다.';
    }
  }

  static String newInviteCodeGenerated(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'New invite code generated';
      case 'ja':
        return '新しい招待コードが発行されました';
      default:
        return '새 초대 코드 발급';
    }
  }

  static String inviteCodeValidFor(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'You can use this code for 3 minutes.';
      case 'ja':
        return 'このコードは3分間使用できます。';
      default:
        return '3분 동안 사용할 수 있는 코드를 만들었어요.';
    }
  }

  static String logoutError(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'An error occurred during logout: ';
      case 'ja':
        return 'ログアウト中にエラーが発生しました: ';
      default:
        return '로그아웃 중 오류가 발생했습니다: ';
    }
  }

  // 편지 쓰기 화면
  static String writeLetter(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Write Letter';
      case 'ja':
        return '手紙を書く';
      default:
        return '편지 쓰기';
    }
  }

  static String title(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Title';
      case 'ja':
        return 'タイトル';
      default:
        return '제목';
    }
  }

  static String titleHint(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Enter title...';
      case 'ja':
        return 'タイトルを入力...';
      default:
        return '제목을 입력하세요...';
    }
  }

  static String content(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Content';
      case 'ja':
        return '内容';
      default:
        return '내용';
    }
  }

  static String contentHint(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Write your letter here...';
      case 'ja':
        return 'ここに手紙を書いてください...';
      default:
        return '편지 내용을 작성하세요...';
    }
  }

  static String preview(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Preview';
      case 'ja':
        return 'プレビュー';
      default:
        return '미리보기';
    }
  }

  static String previewHint(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Preview text (displayed in bouquet)';
      case 'ja':
        return 'プレビューテキスト（花束に表示）';
      default:
        return '미리보기 텍스트 (꽃다발에 표시됩니다)';
    }
  }

  static String send(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Send';
      case 'ja':
        return '送信';
      default:
        return '보내기';
    }
  }

  static String titleRequired(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter a title';
      case 'ja':
        return 'タイトルを入力してください';
      default:
        return '제목을 입력해주세요';
    }
  }

  static String pastTimeError(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Cannot schedule for a past time';
      case 'ja':
        return '過去の時間に予約することはできません';
      default:
        return '과거 시간으로 예약할 수 없습니다';
    }
  }

  static String contentRequired(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter content';
      case 'ja':
        return '内容を入力してください';
      default:
        return '내용을 입력해주세요';
    }
  }

  static String previewRequired(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter preview text';
      case 'ja':
        return 'プレビューテキストを入力してください';
      default:
        return '미리보기 텍스트를 입력해주세요';
    }
  }

  // 프로필 편집
  static String editProfile(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Edit Profile';
      case 'ja':
        return 'プロフィール編集';
      default:
        return '프로필 편집';
    }
  }


  static String save(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Save';
      case 'ja':
        return '保存';
      default:
        return '저장';
    }
  }

  static String profileUpdateFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to update profile';
      case 'ja':
        return 'プロフィールの更新に失敗しました';
      default:
        return '프로필 수정에 실패했습니다';
    }
  }

  // 회원가입 화면 추가
  static String selectProfilePhoto(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Select Profile Photo (Optional)';
      case 'ja':
        return 'プロフィール写真を選択（オプション）';
      default:
        return '프로필 사진 선택 (선택사항)';
    }
  }

  static String viewTerms(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'View';
      case 'ja':
        return '表示';
      default:
        return '보기';
    }
  }

  static String agreeToTerms(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'I agree to the Terms of Service.';
      case 'ja':
        return 'サービス利用規約に同意します。';
      default:
        return '서비스 이용약관에 동의합니다.';
    }
  }

  static String agreeToPrivacy(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'I agree to the Privacy Policy.';
      case 'ja':
        return 'プライバシーポリシーに同意します。';
      default:
        return '개인정보 처리방침에 동의합니다.';
    }
  }

  // 꽃 이름
  static String flowerName(Locale locale, String flowerType) {
    switch (flowerType) {
      case 'rose':
        switch (locale.languageCode) {
          case 'en':
            return 'Rose';
          case 'ja':
            return 'バラ';
          default:
            return '장미';
        }
      case 'tulip':
        switch (locale.languageCode) {
          case 'en':
            return 'Tulip';
          case 'ja':
            return 'チューリップ';
          default:
            return '튤립';
        }
      case 'sakura':
        switch (locale.languageCode) {
          case 'en':
            return 'Cherry Blossom';
          case 'ja':
            return '桜';
          default:
            return '벚꽃';
        }
      case 'sunflower':
        switch (locale.languageCode) {
          case 'en':
            return 'Sunflower';
          case 'ja':
            return 'ひまわり';
          default:
            return '해바라기';
        }
      case 'daisy':
        switch (locale.languageCode) {
          case 'en':
            return 'Daisy';
          case 'ja':
            return 'デイジー';
          default:
            return '데이지';
        }
      case 'lavender':
        switch (locale.languageCode) {
          case 'en':
            return 'Lavender';
          case 'ja':
            return 'ラベンダー';
          default:
            return '라벤더';
        }
      default:
        return flowerType;
    }
  }

  static String seedLabel(Locale locale, String flowerName) {
    switch (locale.languageCode) {
      case 'en':
        return '$flowerName Seed';
      case 'ja':
        return '$flowerNameの種';
      default:
        return '$flowerName 씨앗';
    }
  }

  // 공개 범위
  static String visibilityScope(Locale locale, String scope) {
    switch (scope) {
      case 'public':
        switch (locale.languageCode) {
          case 'en':
            return 'Public';
          case 'ja':
            return '全体公開';
          default:
            return '전체 공개';
        }
      case 'friends':
        switch (locale.languageCode) {
          case 'en':
            return 'Friends Only';
          case 'ja':
            return '友達のみ';
          default:
            return '친구만';
        }
      case 'direct':
        switch (locale.languageCode) {
          case 'en':
            return 'Specific Person';
          case 'ja':
            return '特定の人';
          default:
            return '특정인';
        }
      case 'private':
        switch (locale.languageCode) {
          case 'en':
            return 'Private';
          case 'ja':
            return '自分だけ';
          default:
            return '나만 보기';
        }
      default:
        return scope;
    }
  }

  static String toFriend(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'To Friend';
      case 'ja':
        return '友達へ';
      default:
        return '친구에게';
    }
  }

  // 시간 표시
  static String timeAgo(Locale locale, DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    
    if (diff.inMinutes < 1) {
      switch (locale.languageCode) {
        case 'en':
          return 'Just now';
        case 'ja':
          return 'たった今';
        default:
          return '방금 전';
      }
    }
    
    if (diff.inMinutes < 60) {
      switch (locale.languageCode) {
        case 'en':
          return '${diff.inMinutes}m ago';
        case 'ja':
          return '${diff.inMinutes}分前';
        default:
          return '${diff.inMinutes}분 전';
      }
    }
    
    if (diff.inHours < 24) {
      switch (locale.languageCode) {
        case 'en':
          return '${diff.inHours}h ago';
        case 'ja':
          return '${diff.inHours}時間前';
        default:
          return '${diff.inHours}시간 전';
      }
    }
    
    switch (locale.languageCode) {
      case 'en':
        return '${diff.inDays}d ago';
      case 'ja':
        return '${diff.inDays}日前';
      default:
        return '${diff.inDays}일 전';
    }
  }

  static String anonymous(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Anonymous';
      case 'ja':
        return '匿名';
      default:
        return '익명';
    }
  }

  // 편지 쓰기 화면
  static String noLettersYet(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'No letters yet';
      case 'ja':
        return 'まだ手紙がありません';
      default:
        return '아직 편지가 없어요';
    }
  }

  static String writeLetterToStart(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Write a letter to start the conversation';
      case 'ja':
        return '手紙を書いて会話を始めましょう';
      default:
        return '편지를 써서 대화를 시작해보세요';
    }
  }

  static String scheduledLetterMessage(Locale locale, DateTime scheduledAt) {
    final now = DateTime.now();
    final diff = scheduledAt.difference(now);
    
    String timeStr;
    if (diff.inDays > 0) {
      timeStr = '${diff.inDays}일 후';
    } else if (diff.inHours > 0) {
      timeStr = '${diff.inHours}시간 후';
    } else if (diff.inMinutes > 0) {
      timeStr = '${diff.inMinutes}분 후';
    } else {
      timeStr = '곧';
    }
    
    switch (locale.languageCode) {
      case 'en':
        return 'Scheduled to send in $timeStr';
      case 'ja':
        return '$timeStr に送信予定';
      default:
        return '$timeStr 예약 전송';
    }
  }

  static String writeLetterButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Write Letter';
      case 'ja':
        return '手紙を書く';
      default:
        return '편지 쓰기';
    }
  }

  static String sendSettings(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Send Settings';
      case 'ja':
        return '送信設定';
      default:
        return '보내기 설정';
    }
  }

  static String replyAutoMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Replies are automatically sent to the recipient.';
      case 'ja':
        return '返信は自動的に相手に送信されます。';
      default:
        return '답장은 자동으로 상대방에게 전송됩니다';
    }
  }

  static String selectFriend(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Select Friend';
      case 'ja':
        return '友達を選択';
      default:
        return '친구 선택';
    }
  }

  static String noFriends(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'No friends yet';
      case 'ja':
        return 'まだ友達がいません';
      default:
        return '친구가 없습니다';
    }
  }

  static String replyRecipient(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Reply Recipient';
      case 'ja':
        return '返信先';
      default:
        return '답장 수신자';
    }
  }

  static String scheduledSend(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Scheduled Send';
      case 'ja':
        return '予約送信';
      default:
        return '예약 발송';
    }
  }

  static String scheduledSendSubtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Set the time when the seed will bloom';
      case 'ja':
        return '種が咲く時間を指定します';
      default:
        return '씨앗이 피어날 시간을 지정합니다';
    }
  }

  static String selectDate(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Select Date';
      case 'ja':
        return '日付を選択';
      default:
        return '날짜 선택';
    }
  }

  static String selectTime(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Select Time';
      case 'ja':
        return '時間を選択';
      default:
        return '시간 선택';
    }
  }

  static String sending(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Sending...';
      case 'ja':
        return '送信中...';
      default:
        return '전송 중...';
    }
  }

  static String plantSeed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Plant Seed';
      case 'ja':
        return '種をまく';
      default:
        return '씨앗 뿌리기';
    }
  }

  static String seedPlanted(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Seed Planted';
      case 'ja':
        return '種をまきました';
      default:
        return '씨앗을 뿌렸어요';
    }
  }

  static String seedFliesMessage(Locale locale, String target) {
    switch (locale.languageCode) {
      case 'en':
        return 'Recipient: $target\nThe seed flies to the neon sky right away.';
      case 'ja':
        return '受信者: $target\n種はすぐにネオンの空へ飛んでいきます。';
      default:
        return '받는 대상: $target\n씨앗은 바로 네온 하늘로 날아가요.';
    }
  }

  static String seedBloomsMessage(Locale locale, String target, String date, String time) {
    switch (locale.languageCode) {
      case 'en':
        return 'Recipient: $target\nThe seed will bloom on $date at $time.';
      case 'ja':
        return '受信者: $target\n種は$dateの$timeに咲きます。';
      default:
        return '받는 대상: $target\n씨앗은 $date $time에 피어날 거예요.';
    }
  }

  static String letterSendFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to send letter. Please try again.';
      case 'ja':
        return '手紙の送信に失敗しました。もう一度お試しください。';
      default:
        return '편지 전송에 실패했습니다. 다시 시도해주세요.';
    }
  }

  static String friend(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Friend';
      case 'ja':
        return '友達';
      default:
        return '친구';
    }
  }

  // 신고 관련
  static String reportReason(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Reason';
      case 'ja':
        return '理由';
      default:
        return '사유';
    }
  }

  static String reportReasonSpam(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Spam/Advertisement';
      case 'ja':
        return 'スパム/広告';
      default:
        return '스팸/광고';
    }
  }

  static String reportReasonHate(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Hate/Discrimination';
      case 'ja':
        return '憎悪/差別';
      default:
        return '혐오/차별';
    }
  }

  static String reportReasonHarassment(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Profanity/Harassment';
      case 'ja':
        return '悪質な嫌がらせ/いじめ';
      default:
        return '욕설/괴롭힘';
    }
  }

  static String reportReasonPrivacy(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Privacy Violation';
      case 'ja':
        return 'プライバシー侵害';
      default:
        return '개인정보 노출';
    }
  }

  static String reportReasonOther(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Other';
      case 'ja':
        return 'その他';
      default:
        return '기타';
    }
  }

  static String reportDetails(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Details (Optional)';
      case 'ja':
        return '詳細（任意）';
      default:
        return '상세 내용 (선택)';
    }
  }

  static String reportDetailsHint(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please provide detailed information';
      case 'ja':
        return '詳細な内容を記入してください';
      default:
        return '상세한 내용을 적어주세요';
    }
  }

  static String submitReport(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Submit Report';
      case 'ja':
        return '報告を提出';
      default:
        return '신고 접수';
    }
  }

  // 꽃다발 관련
  static String bouquetDetail(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Bouquet Details';
      case 'ja':
        return '花束の詳細';
      default:
        return '꽃다발 상세';
    }
  }

  static String bouquetWithFriend(Locale locale, String friendName) {
    switch (locale.languageCode) {
      case 'en':
        return 'Bouquet with $friendName';
      case 'ja':
        return '$friendNameとの花束';
      default:
        return '$friendName과 만든 꽃다발';
    }
  }

  static String bouquetName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Bouquet Name';
      case 'ja':
        return '花束の名前';
      default:
        return '꽃다발 이름';
    }
  }

  static String bouquetNameSaved(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Bouquet name saved';
      case 'ja':
        return '花束の名前を保存しました';
      default:
        return '꽃다발 이름을 저장했어요';
    }
  }

  static String deleteFriend(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Remove Friend';
      case 'ja':
        return '友達を削除';
      default:
        return '친구 끊기';
    }
  }

  static String deleteFriendConfirm(Locale locale, String friendName) {
    switch (locale.languageCode) {
      case 'en':
        return 'Are you sure you want to remove $friendName from your friends?';
      case 'ja':
        return '$friendNameを友達から削除してもよろしいですか？';
      default:
        return '$friendName님과 친구를 끊으시겠습니까?';
    }
  }

  static String friendDeleted(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Friend removed';
      case 'ja':
        return '友達が削除されました';
      default:
        return '친구가 삭제되었습니다';
    }
  }

  static String friendDeletedMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'The friend has been removed from your friends list.';
      case 'ja':
        return '友達が友達リストから削除されました。';
      default:
        return '친구가 친구 목록에서 삭제되었습니다.';
    }
  }

  static String shareBouquet(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Share Bouquet';
      case 'ja':
        return '花束を共有';
      default:
        return '꽃다발 공유하기';
    }
  }

  static String cannotLoadLetters(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Cannot load letters';
      case 'ja':
        return '手紙を読み込めません';
      default:
        return '편지를 불러올 수 없습니다';
    }
  }

  static String bouquetShareTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '[Taba Bouquet Share]';
      case 'ja':
        return '[Taba花束共有]';
      default:
        return '[Taba 꽃다발 공유]';
    }
  }

  static String bouquetShareMessage(Locale locale, String friendName, int count) {
    switch (locale.languageCode) {
      case 'en':
        return '$count flowers shared with $friendName';
      case 'ja':
        return '$friendNameと共有した$count個の花';
      default:
        return '$friendName과 나눈 꽃 $count개';
    }
  }

  static String inviteFriendsMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Catch seeds in Taba and become friends with me!';
      case 'ja':
        return 'Tabaで種を捕まえて、私と友達になりましょう！';
      default:
        return 'Taba에서 씨앗을 잡아 나와 친구가 되어줘!';
    }
  }

  static String bouquetShared(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Bouquet share link copied';
      case 'ja':
        return '花束共有リンクをコピーしました';
      default:
        return '꽃다발 공유 링크 복사';
    }
  }

  static String shareBouquetMessage(Locale locale, String friendName) {
    switch (locale.languageCode) {
      case 'en':
        return 'Share your bouquet with $friendName with your friends.';
      case 'ja':
        return '$friendNameとの花束を友達に伝えてください。';
      default:
        return '$friendName과의 꽃다발을 친구에게 전해보세요.';
    }
  }

  // 성공/오류 메시지
  static String successTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Success';
      case 'ja':
        return '成功';
      default:
        return '성공';
    }
  }

  static String viewAttachedPhotos(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'View Attached Photos';
      case 'ja':
        return '添付写真を見る';
      default:
        return '첨부한 사진 보기';
    }
  }

  static String errorTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Error';
      case 'ja':
        return 'エラー';
      default:
        return '오류';
    }
  }

  // 튜토리얼
  static String skipTutorial(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Skip';
      case 'ja':
        return 'スキップ';
      default:
        return '건너뛰기';
    }
  }

  static String tutorialNext(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Next';
      case 'ja':
        return '次へ';
      default:
        return '다음';
    }
  }

  static String tutorialStart(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Get Started';
      case 'ja':
        return '始める';
      default:
        return '시작하기';
    }
  }

  // 튜토리얼 페이지별 텍스트
  static String tutorialPage1Title(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Welcome to Taba';
      case 'ja':
        return 'Tabaへようこそ';
      default:
        return 'Taba에 오신 것을 환영해요';
    }
  }

  static String tutorialPage1Subtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Catch floating seeds and bloom flowers';
      case 'ja':
        return '浮かぶ種を捕まえて花を咲かせましょう';
      default:
        return '떠다니는 씨앗을 잡아 꽃을 피워보세요';
    }
  }

  static String tutorialPage2Title(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Catch Seeds';
      case 'ja':
        return '種を捕まえる';
      default:
        return '씨앗 잡기';
    }
  }

  static String tutorialPage2Subtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Tap the sparkling seeds in the sky to open letters';
      case 'ja':
        return '空に輝く種をタップして手紙を開きましょう';
      default:
        return '하늘에서 반짝이는 씨앗을 탭해 편지를 열어봐요';
    }
  }

  static String tutorialPage3Title(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'New Connections';
      case 'ja':
        return '新しい出会い';
      default:
        return '새로운 인연과 우정';
    }
  }

  static String tutorialPage3Subtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Form new connections or deepen friendships through letters';
      case 'ja':
        return '新しい出会いを、または友情を深めましょう';
      default:
        return '새로운 인연을 꽃피우고\n친구와 함께 성장해요';
    }
  }

  static String tutorialPage4Title(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Your Bouquet';
      case 'ja':
        return 'あなたの花束';
      default:
        return '나만의 꽃다발';
    }
  }

  static String tutorialPage4Subtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Collect your favorite letters to create your own bouquet';
      case 'ja':
        return 'お気に入りの手紙を集めて自分だけの花束を作りましょう';
      default:
        return '좋아하는 편지를 모아 나만의 꽃다발을 만들어요';
    }
  }

  // 설정 화면 추가
  static String settingsLoadFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to load settings: ';
      case 'ja':
        return '設定の読み込みに失敗しました: ';
      default:
        return '설정을 불러오는데 실패했습니다: ';
    }
  }

  static String reallyLogout(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Do you really want to logout?';
      case 'ja':
        return '本当にログアウトしますか？';
      default:
        return '정말 로그아웃 하시겠습니까?';
    }
  }

  static String cannotLoadUserInfo(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Cannot load user information. Please login again.';
      case 'ja':
        return 'ユーザー情報を読み込めません。再度ログインしてください。';
      default:
        return '사용자 정보를 불러올 수 없습니다. 다시 로그인해주세요.';
    }
  }

  static String settingsLoadFailed2(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to load settings: ';
      case 'ja':
        return '設定の読み込みに失敗しました: ';
      default:
        return '설정을 불러오는데 실패했습니다: ';
    }
  }

  static String editProfileTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Edit Profile';
      case 'ja':
        return 'プロフィール編集';
      default:
        return '프로필 수정';
    }
  }

  // 약관 화면
  static String agreeAndClose(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Agree and Close';
      case 'ja':
        return '同意して閉じる';
      default:
        return '동의하고 닫기';
    }
  }

  static String termsContent(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'These terms are related to service use... (sample text)';
      case 'ja':
        return '本規約はサービス利用に関連して... (サンプルテキスト)';
      default:
        return '본 약관은 서비스 이용과 관련하여... (샘플 텍스트)';
    }
  }

  static String privacyContent(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'We collect minimal personal information for service provision... (sample text)';
      case 'ja':
        return '当社はサービス提供のために最小限の個人情報を収集します... (サンプルテキスト)';
      default:
        return '당사는 서비스 제공을 위해 최소한의 개인정보를 수집하며... (샘플 텍스트)';
    }
  }

  static String tabaTerms(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Taba Terms of Service';
      case 'ja':
        return 'Taba利用規約';
      default:
        return 'Taba 이용약관';
    }
  }

  static String privacyPolicy(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Privacy Policy';
      case 'ja':
        return 'プライバシーポリシー';
      default:
        return '개인정보 처리방침';
    }
  }

  // 편지 쓰기 화면 추가
  static String premiumTemplatesComing(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '* Season / Premium templates are coming soon.';
      case 'ja':
        return '* シーズン/プレミアムテンプレートは近日公開予定です。';
      default:
        return '* 시즌 / 프리미엄 템플릿은 곧 추가될 예정이에요.';
    }
  }

  // 공유 및 기타
  static String inviteCode(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Invite Code: ';
      case 'ja':
        return '招待コード: ';
      default:
        return '초대 코드: ';
    }
  }

  static String loadFriendsFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to load friends list: ';
      case 'ja':
        return '友達リストの読み込みに失敗しました: ';
      default:
        return '친구 목록을 불러오는데 실패했습니다: ';
    }
  }

  // 공개 편지 섹션
  static String publicLetterSection(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Public Letters';
      case 'ja':
        return '公開手紙';
      default:
        return '공개 편지';
    }
  }

  static String languageFilter(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Language Filter';
      case 'ja':
        return '言語フィルター';
      default:
        return '언어 필터';
    }
  }

  static String languageFilterDescription(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'You can only see letters in the desired language';
      case 'ja':
        return '希望する言語の手紙だけを見ることができます';
      default:
        return '원하는 언어의 편지만 볼 수 있어요';
    }
  }
}

