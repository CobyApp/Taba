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

  static String newNotification(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'New Notification';
      case 'ja':
        return '新しい通知';
      default:
        return '새 알림';
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

  static String invalidCredentials(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Email or password is incorrect.';
      case 'ja':
        return 'メールアドレスまたはパスワードが正しくありません。';
      default:
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }
  }

  static String networkTimeout(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Connection timeout. Please check your network and try again.';
      case 'ja':
        return '接続がタイムアウトしました。ネットワークを確認してもう一度お試しください。';
      default:
        return '연결 시간이 초과되었습니다. 네트워크를 확인하고 다시 시도해주세요.';
    }
  }

  static String networkConnectionError(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Network connection error. Please check your internet connection.';
      case 'ja':
        return 'ネットワーク接続エラー。インターネット接続を確認してください。';
      default:
        return '네트워크 연결 오류가 발생했습니다. 인터넷 연결을 확인해주세요.';
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

  static String cameraNotAvailable(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Camera is not available on this device. Please use the gallery instead.';
      case 'ja':
        return 'このデバイスではカメラを使用できません。ギャラリーから選択してください。';
      default:
        return '이 기기에서는 카메라를 사용할 수 없습니다. 갤러리에서 선택해주세요.';
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

  /// 친구 추가 알림 제목 (닉네임 뒤에 붙일 텍스트)
  static String friendAddedTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return ' has been added as a friend';
      case 'ja':
        return 'さんが友達として追加されました';
      default:
        return '님이 친구로 추가되었어요';
    }
  }

  /// 친구 요청 수락 알림 제목 (닉네임 뒤에 붙일 텍스트)
  static String friendRequestAcceptedTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return ' accepted your friend request';
      case 'ja':
        return 'さんが友達リクエストを承認しました';
      default:
        return '님이 친구 요청을 수락했어요';
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

  static String deleteButton(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Delete';
      case 'ja':
        return '削除';
      default:
        return '삭제';
    }
  }

  static String deleteLetter(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Delete Letter';
      case 'ja':
        return '手紙を削除';
      default:
        return '편지 삭제';
    }
  }

  static String deleteLetterConfirm(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Are you sure you want to delete this letter? This action cannot be undone.';
      case 'ja':
        return 'この手紙を削除してもよろしいですか？この操作は元に戻せません。';
      default:
        return '이 편지를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
    }
  }

  static String letterDeleted(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Letter deleted';
      case 'ja':
        return '手紙が削除されました';
      default:
        return '편지가 삭제되었습니다';
    }
  }

  static String letterDeletedMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'The letter has been deleted.';
      case 'ja':
        return '手紙が削除されました。';
      default:
        return '편지가 삭제되었습니다.';
    }
  }

  static String letterDeleteFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to delete letter.';
      case 'ja':
        return '手紙の削除に失敗しました。';
      default:
        return '편지 삭제에 실패했습니다.';
    }
  }

  static String letterNotFound(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'This letter has been deleted.';
      case 'ja':
        return 'この手紙は削除されました。';
      default:
        return '이 편지는 삭제되었습니다.';
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

  static String loadDataFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to load data';
      case 'ja':
        return 'データの読み込みに失敗しました';
      default:
        return '데이터를 불러오는데 실패했습니다';
    }
  }

  static String photoSelectionError(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'An error occurred while selecting photo';
      case 'ja':
        return '写真の選択中にエラーが発生しました';
      default:
        return '사진 선택 중 오류가 발생했습니다';
    }
  }

  static String reportSubmitted(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Report submitted. We will review and take action.';
      case 'ja':
        return '報告が受理されました。確認後、対応いたします。';
      default:
        return '신고가 접수되었습니다. 검토 후 조치하겠습니다.';
    }
  }

  static String reportFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to submit report. Please try again.';
      case 'ja':
        return '報告の送信に失敗しました。もう一度お試しください。';
      default:
        return '신고 접수에 실패했습니다. 다시 시도해주세요.';
    }
  }

  static String letterListLoadFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to load letter list';
      case 'ja':
        return '手紙リストの読み込みに失敗しました';
      default:
        return '편지 목록을 불러오는데 실패했습니다';
    }
  }

  static String emailRequired(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter your email';
      case 'ja':
        return 'メールアドレスを入力してください';
      default:
        return '이메일을 입력해주세요';
    }
  }

  static String passwordResetEmailSent(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Password reset email has been sent.';
      case 'ja':
        return 'パスワードリセットメールを送信しました。';
      default:
        return '비밀번호 재설정 메일을 보냈어요.';
    }
  }

  static String emailSendFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to send email. Please try again.';
      case 'ja':
        return 'メールの送信に失敗しました。もう一度お試しください。';
      default:
        return '이메일 전송에 실패했습니다. 다시 시도해주세요.';
    }
  }

  static String compressingImage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Compressing image...';
      case 'ja':
        return '画像を圧縮中...';
      default:
        return '이미지를 압축하는 중...';
    }
  }

  static String downloadingImage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Downloading image...';
      case 'ja':
        return '画像をダウンロード中...';
      default:
        return '이미지를 다운로드하는 중...';
    }
  }

  static String shareFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to share';
      case 'ja':
        return '共有に失敗しました';
      default:
        return '공유에 실패했습니다';
    }
  }

  static String share(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Share';
      case 'ja':
        return '共有';
      default:
        return '공유하기';
    }
  }

  static String confirm(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Confirm';
      case 'ja':
        return '確認';
      default:
        return '확인';
    }
  }

  static String someImagesUploadFailed(Locale locale, int uploaded, int total) {
    switch (locale.languageCode) {
      case 'en':
        return 'Some images failed to upload. ($uploaded/$total)';
      case 'ja':
        return '一部の画像のアップロードに失敗しました。 ($uploaded/$total)';
      default:
        return '일부 이미지 업로드에 실패했습니다. ($uploaded/$total)';
    }
  }

  static String imageUploadFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to upload images';
      case 'ja':
        return '画像のアップロ드に失敗しました';
      default:
        return '이미지 업로드에 실패했습니다';
    }
  }

  static String korean(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Korean';
      case 'ja':
        return '韓国語';
      default:
        return '한국어';
    }
  }

  static String inviteCodeExample(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'e.g., A1B2C3';
      case 'ja':
        return '例: A1B2C3';
      default:
        return '예: A1B2C3';
    }
  }

  static String inviteCodeGenerationError(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'An error occurred while generating invite code';
      case 'ja':
        return '招待コード生成中にエラーが発生しました';
      default:
        return '초대 코드 생성 중 오류가 발생했습니다';
    }
  }

  static String seed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Seed';
      case 'ja':
        return '種';
      default:
        return '씨앗';
    }
  }

  static String flower(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Flower';
      case 'ja':
        return '花';
      default:
        return '꽃';
    }
  }

  static String letterCommunicationSpace(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'A space to communicate through letters';
      case 'ja':
        return '手紙でコミュニケーションする空間';
      default:
        return '편지로 소통하는 공간';
    }
  }

  static String translate(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Translate';
      case 'ja':
        return '翻訳';
      default:
        return '번역';
    }
  }

  static String translating(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Translating...';
      case 'ja':
        return '翻訳中...';
      default:
        return '번역 중...';
    }
  }

  static String showOriginal(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Show Original';
      case 'ja':
        return '原文を表示';
      default:
        return '원문 보기';
    }
  }

  static String translationFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Translation failed. Please try again.';
      case 'ja':
        return '翻訳に失敗しました。もう一度お試しください。';
      default:
        return '번역에 실패했습니다. 다시 시도해주세요.';
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
        return '''Article 1 (Purpose)
These Terms of Service ("Terms") govern the use of the Taba service ("Service") provided by Taba ("Company"). The purpose of these Terms is to define the rights, obligations, and responsibilities of the Company and users in using the Service.

Article 2 (Definitions)
1. "Service" refers to the Taba letter exchange platform and all related services provided by the Company.
2. "User" refers to any individual who accesses and uses the Service in accordance with these Terms.
3. "Content" refers to letters, images, and all other materials created, posted, or transmitted by users through the Service.

Article 3 (Acceptance of Terms)
By accessing or using the Service, users agree to be bound by these Terms. If you do not agree to these Terms, you may not use the Service.

Article 4 (Service Provision)
1. The Company provides a platform for users to exchange letters with friends and discover public letters.
2. The Company may modify, suspend, or terminate the Service at any time with or without notice.
3. The Company is not responsible for any loss or damage resulting from service interruptions or modifications.

Article 5 (User Obligations)
1. Users must provide accurate information when registering for the Service.
2. Users must not engage in any illegal activities or violate the rights of others.
3. Users must not post content that is defamatory, obscene, or violates public order and morals.
4. Users must not interfere with the operation of the Service or attempt to access the Service through unauthorized means.

Article 6 (Intellectual Property)
1. All content created by users belongs to the users who created it.
2. Users grant the Company a license to use, store, and display their content for the purpose of providing the Service.
3. The Company owns all intellectual property rights in the Service itself, including its design, functionality, and branding.

Article 7 (Privacy)
The Company respects user privacy. Please refer to our Privacy Policy for details on how we collect, use, and protect your personal information.

Article 8 (Service Suspension and Termination)
1. The Company may suspend or terminate a user's access to the Service if the user violates these Terms.
2. Users may terminate their account at any time through the Service settings.

Article 9 (Disclaimer)
1. The Company does not guarantee the accuracy, completeness, or reliability of any content posted by users.
2. The Company is not liable for any damages arising from the use or inability to use the Service.
3. The Company is not responsible for disputes between users.

Article 10 (Changes to Terms)
The Company may modify these Terms at any time. Users will be notified of significant changes, and continued use of the Service constitutes acceptance of the modified Terms.

Article 11 (Governing Law)
These Terms shall be governed by and construed in accordance with the laws of the Republic of Korea.

Effective Date: These Terms are effective as of the date of user registration.''';
      case 'ja':
        return '''第1条（目的）
本利用規約（「規約」）は、Taba（「当社」）が提供するTabaサービス（「サービス」）の利用に関する条件を定めるものです。本規約は、サービス利用に関連する当社とユーザー間の権利、義務、責任を規定することを目的とします。

第2条（定義）
1. 「サービス」とは、当社が提供するTaba手紙交換プラットフォームおよび関連するすべてのサービスを指します。
2. 「ユーザー」とは、本規約に従ってサービスにアクセスし、利用するすべての個人を指します。
3. 「コンテンツ」とは、ユーザーがサービスを通じて作成、投稿、または送信する手紙、画像、その他すべての資料を指します。

第3条（規約の受諾）
サービスにアクセスまたは利用することにより、ユーザーは本規約に拘束されることに同意したものとみなされます。本規約に同意しない場合、サービスを利用することはできません。

第4条（サービスの提供）
1. 当社は、ユーザーが友人と手紙を交換し、公開手紙を発見できるプラットフォームを提供します。
2. 当社は、事前通知の有無に関わらず、いつでもサービスを変更、中断、または終了することができます。
3. 当社は、サービス中断または変更に起因するいかなる損失または損害についても責任を負いません。

第5条（ユーザーの義務）
1. ユーザーは、サービス登録時に正確な情報を提供しなければなりません。
2. ユーザーは、違法行為を行ったり、他人の権利を侵害したりしてはなりません。
3. ユーザーは、中傷的、わいせつ、または公序良俗に反するコンテンツを投稿してはなりません。
4. ユーザーは、サービスの運営を妨害したり、不正な手段でサービスにアクセスしようとしたりしてはなりません。

第6条（知的財産権）
1. ユーザーが作成したすべてのコンテンツは、そのコンテンツを作成したユーザーに帰属します。
2. ユーザーは、サービス提供の目的で、当社にコンテンツの使用、保存、表示を許可するライセンスを付与します。
3. 当社は、デザイン、機能、ブランディングを含むサービス自体のすべての知的財産権を所有します。

第7条（プライバシー）
当社はユーザーのプライバシーを尊重します。個人情報の収集、使用、保護に関する詳細は、プライバシーポリシーを参照してください。

第8条（サービスの中断および終了）
1. 当社は、ユーザーが本規約に違反した場合、ユーザーのサービスへのアクセスを中断または終了することができます。
2. ユーザーは、サービス設定を通じていつでもアカウントを終了することができます。

第9条（免責事項）
1. 当社は、ユーザーが投稿したコンテンツの正確性、完全性、または信頼性を保証しません。
2. 当社は、サービスの使用または使用不能に起因するいかなる損害についても責任を負いません。
3. 当社は、ユーザー間の紛争について責任を負いません。

第10条（規約の変更）
当社は、いつでも本規約を変更することができます。重要な変更についてはユーザーに通知され、サービスの継続的な利用は変更された規約の受諾を構成します。

第11条（準拠法）
本規約は、大韓民国の法律に従って解釈され、準拠します。

発効日：本規約は、ユーザー登録日から発効します。''';
      default:
        return '''제1조 (목적)
본 이용약관("약관")은 Taba("회사")가 제공하는 Taba 서비스("서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"란 회사가 제공하는 Taba 편지 교환 플랫폼 및 이와 관련된 모든 서비스를 의미합니다.
2. "이용자"란 본 약관에 따라 서비스에 접속하여 이용하는 모든 개인을 의미합니다.
3. "콘텐츠"란 이용자가 서비스를 통해 작성, 게시 또는 전송하는 편지, 이미지 및 기타 모든 자료를 의미합니다.

제3조 (약관의 동의)
서비스에 접속하거나 이용함으로써 이용자는 본 약관에 동의한 것으로 간주됩니다. 본 약관에 동의하지 않는 경우 서비스를 이용할 수 없습니다.

제4조 (서비스의 제공)
1. 회사는 이용자가 친구와 편지를 교환하고 공개 편지를 발견할 수 있는 플랫폼을 제공합니다.
2. 회사는 사전 통지 없이 언제든지 서비스를 수정, 중단 또는 종료할 수 있습니다.
3. 회사는 서비스 중단 또는 수정으로 인한 어떠한 손실이나 손해에 대해서도 책임을 지지 않습니다.

제5조 (이용자의 의무)
1. 이용자는 서비스 가입 시 정확한 정보를 제공해야 합니다.
2. 이용자는 불법적인 활동을 하거나 타인의 권리를 침해해서는 안 됩니다.
3. 이용자는 비방적, 음란하거나 공공질서 및 미풍양속에 반하는 콘텐츠를 게시해서는 안 됩니다.
4. 이용자는 서비스 운영을 방해하거나 무단으로 서비스에 접근하려고 시도해서는 안 됩니다.

제6조 (지적재산권)
1. 이용자가 작성한 모든 콘텐츠는 해당 콘텐츠를 작성한 이용자에게 귀속됩니다.
2. 이용자는 서비스 제공을 위한 목적으로 회사에 자신의 콘텐츠를 사용, 저장 및 표시할 수 있는 라이선스를 부여합니다.
3. 회사는 서비스 자체의 디자인, 기능 및 브랜딩을 포함한 모든 지적재산권을 소유합니다.

제7조 (개인정보)
회사는 이용자의 개인정보를 존중합니다. 개인정보의 수집, 사용 및 보호에 대한 자세한 내용은 개인정보처리방침을 참조하시기 바랍니다.

제8조 (서비스의 중단 및 종료)
1. 회사는 이용자가 본 약관을 위반한 경우 이용자의 서비스 이용을 중단하거나 종료할 수 있습니다.
2. 이용자는 서비스 설정을 통해 언제든지 계정을 종료할 수 있습니다.

제9조 (면책조항)
1. 회사는 이용자가 게시한 콘텐츠의 정확성, 완전성 또는 신뢰성을 보장하지 않습니다.
2. 회사는 서비스 이용 또는 이용 불가로 인해 발생하는 어떠한 손해에 대해서도 책임을 지지 않습니다.
3. 회사는 이용자 간의 분쟁에 대해 책임을 지지 않습니다.

제10조 (약관의 변경)
회사는 언제든지 본 약관을 수정할 수 있습니다. 중요한 변경사항에 대해서는 이용자에게 통지하며, 서비스를 계속 이용하는 것은 수정된 약관에 대한 동의로 간주됩니다.

제11조 (준거법)
본 약관은 대한민국 법률에 따라 해석되고 적용됩니다.

시행일: 본 약관은 이용자 등록일부터 시행됩니다.''';
    }
  }

  static String privacyContent(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '''Article 1 (Purpose of Personal Information Processing)
Taba ("Company") collects and processes personal information in accordance with the Personal Information Protection Act to provide the letter exchange service. This Privacy Policy explains how the Company collects, uses, and protects your personal information.

Article 2 (Items of Personal Information Collected)
The Company collects the following personal information for service provision:
1. Required items: Email address, password (encrypted), nickname, profile image
2. Automatically collected items: Device information, IP address, service usage records, access logs

Article 3 (Purpose of Personal Information Processing)
The Company processes personal information for the following purposes:
1. Service provision: User authentication, letter delivery, friend management
2. Service improvement: Service quality enhancement, new service development
3. Customer support: Response to inquiries, complaint handling
4. Security: Prevention of unauthorized use, fraud prevention

Article 4 (Personal Information Processing and Retention Period)
1. The Company processes and retains personal information for the period necessary to achieve the purpose of collection and use.
2. When a user requests account deletion, personal information is immediately deleted, except for information that must be retained in accordance with relevant laws.

Article 5 (Provision of Personal Information to Third Parties)
The Company does not provide personal information to third parties without the user's consent, except in the following cases:
1. When required by law or requested by investigative agencies for investigation purposes
2. When necessary for the protection of life, body, or property of users or third parties

Article 6 (Entrustment of Personal Information Processing)
The Company may entrust personal information processing to external service providers for service operation. In such cases, the Company enters into necessary agreements to ensure the safe management of personal information.

Article 7 (Rights and Obligations of Information Subjects)
Users have the following rights regarding their personal information:
1. Right to access personal information
2. Right to request correction of errors
3. Right to request deletion
4. Right to request suspension of processing

Article 8 (Destruction of Personal Information)
When personal information becomes unnecessary, the Company immediately destroys it. The destruction procedure and method are as follows:
1. Destruction procedure: Information that has achieved its purpose is selected and destroyed
2. Destruction method: Electronic files are permanently deleted in a way that cannot be recovered, and printed materials are shredded or incinerated

Article 9 (Measures to Ensure Personal Information Security)
The Company takes the following technical and administrative measures to ensure personal information security:
1. Encryption of passwords and important data
2. Access control through authentication
3. Regular security inspections and updates
4. Employee training on personal information protection

Article 10 (Personal Information Protection Officer)
The Company designates a personal information protection officer to handle personal information protection matters and user complaints. Users may contact the officer for inquiries or complaints regarding personal information.

Article 11 (Changes to Privacy Policy)
This Privacy Policy may be amended in accordance with changes in laws, policies, or service needs. When significant changes are made, users will be notified through the service.

Effective Date: This Privacy Policy is effective as of the date of user registration.''';
      case 'ja':
        return '''第1条（個人情報の処理目的）
Taba（「当社」）は、手紙交換サービスを提供するため、個人情報保護法に従って個人情報を収集・処理します。本プライバシーポリシーは、当社が個人情報をどのように収集、使用、保護するかを説明するものです。

第2条（収集する個人情報の項目）
当社は、サービス提供のために以下の個人情報を収集します：
1. 必須項目：メールアドレス、パスワード（暗号化）、ニックネーム、プロフィール画像
2. 自動収集項目：デバイス情報、IPアドレス、サービス利用記録、アクセスログ

第3条（個人情報の処理目的）
当社は、以下の目的で個人情報を処理します：
1. サービス提供：ユーザー認証、手紙配信、友達管理
2. サービス改善：サービス品質向上、新サービス開発
3. 顧客サポート：お問い合わせ対応、苦情処理
4. セキュリティ：不正利用の防止、詐欺の防止

第4条（個人情報の処理および保有期間）
1. 当社は、収集・利用目的の達成に必要な期間、個人情報を処理・保有します。
2. ユーザーがアカウント削除を要求した場合、関連法令に従って保有しなければならない情報を除き、個人情報は即座に削除されます。

第5条（第三者への個人情報の提供）
当社は、以下の場合を除き、ユーザーの同意なく第三者に個人情報を提供しません：
1. 法令により要求される場合、または捜査機関が捜査目的で要求する場合
2. ユーザーまたは第三者の生命、身体、財産の保護に必要な場合

第6条（個人情報処理の委託）
当社は、サービス運営のために外部サービス提供者に個人情報処理を委託する場合があります。この場合、当社は個人情報の安全な管理を確保するための必要な契約を締結します。

第7条（情報主体の権利と義務）
ユーザーは、個人情報に関して以下の権利を有します：
1. 個人情報へのアクセス権
2. 誤りの訂正を要求する権利
3. 削除を要求する権利
4. 処理の停止を要求する権利

第8条（個人情報の破棄）
個人情報が不要になった場合、当社は即座に破棄します。破棄手順および方法は以下のとおりです：
1. 破棄手順：目的を達成した情報を選定して破棄
2. 破棄方法：電子ファイルは復元不可能な方法で永続的に削除し、印刷物は粉砕または焼却

第9条（個人情報の安全性確保措置）
当社は、個人情報の安全性を確保するために以下の技術的・管理的措置を講じます：
1. パスワードおよび重要データの暗号化
2. 認証によるアクセス制御
3. 定期的なセキュリティ検査および更新
4. 個人情報保護に関する従業員教育

第10条（個人情報保護責任者）
当社は、個人情報保護に関する事項およびユーザーの苦情を処理するために個人情報保護責任者を指定しています。ユーザーは、個人情報に関するお問い合わせや苦情について責任者に連絡することができます。

第11条（プライバシーポリシーの変更）
本プライバシーポリシーは、法令、政策、またはサービスのニーズの変更に従って修正される場合があります。重要な変更が行われた場合、サービスを通じてユーザーに通知されます。

発効日：本プライバシーポリシーは、ユーザー登録日から発効します。''';
      default:
        return '''제1조 (개인정보의 처리목적)
Taba("회사")는 편지 교환 서비스를 제공하기 위하여 개인정보보호법에 따라 개인정보를 수집·처리합니다. 본 개인정보처리방침은 회사가 개인정보를 어떻게 수집, 사용, 보호하는지 설명합니다.

제2조 (수집하는 개인정보의 항목)
회사는 서비스 제공을 위해 다음과 같은 개인정보를 수집합니다:
1. 필수 항목: 이메일 주소, 비밀번호(암호화), 닉네임, 프로필 이미지
2. 자동 수집 항목: 기기 정보, IP 주소, 서비스 이용 기록, 접속 로그

제3조 (개인정보의 처리목적)
회사는 다음의 목적을 위하여 개인정보를 처리합니다:
1. 서비스 제공: 회원 인증, 편지 전달, 친구 관리
2. 서비스 개선: 서비스 품질 향상, 신규 서비스 개발
3. 고객 지원: 문의 응대, 불만 처리
4. 보안: 부정 이용 방지, 사기 방지

제4조 (개인정보의 처리 및 보유기간)
1. 회사는 수집·이용 목적이 달성된 때까지 개인정보를 처리·보유합니다.
2. 이용자가 계정 삭제를 요청한 경우, 관련 법령에 따라 보존하여야 하는 정보를 제외하고는 개인정보를 즉시 삭제합니다.

제5조 (개인정보의 제3자 제공)
회사는 이용자의 동의 없이 제3자에게 개인정보를 제공하지 않으며, 다음의 경우에는 예외로 합니다:
1. 법령에 의해 요구되는 경우 또는 수사기관이 수사 목적으로 요청하는 경우
2. 이용자 또는 제3자의 생명, 신체, 재산의 보호를 위하여 필요한 경우

제6조 (개인정보 처리의 위탁)
회사는 서비스 운영을 위해 외부 서비스 제공업체에 개인정보 처리를 위탁할 수 있습니다. 이 경우 회사는 개인정보의 안전한 관리를 위해 필요한 계약을 체결합니다.

제7조 (정보주체의 권리·의무)
이용자는 자신의 개인정보에 대해 다음과 같은 권리를 가집니다:
1. 개인정보 열람 요구권
2. 오류 정정 요구권
3. 삭제 요구권
4. 처리정지 요구권

제8조 (개인정보의 파기)
개인정보가 불필요하게 되었을 때에는 지체 없이 파기합니다. 파기 절차 및 방법은 다음과 같습니다:
1. 파기 절차: 목적 달성된 정보를 선정하여 파기
2. 파기 방법: 전자적 파일은 복구 불가능한 방법으로 영구 삭제하며, 출력물은 분쇄하거나 소각

제9조 (개인정보의 안전성 확보조치)
회사는 개인정보의 안전성 확보를 위해 다음과 같은 기술적·관리적 조치를 취합니다:
1. 비밀번호 및 중요 데이터의 암호화
2. 인증을 통한 접근 제어
3. 정기적인 보안 점검 및 업데이트
4. 개인정보 보호를 위한 직원 교육

제10조 (개인정보 보호책임자)
회사는 개인정보 보호에 관한 사항 및 이용자의 불만을 처리하기 위하여 개인정보 보호책임자를 지정합니다. 이용자는 개인정보에 관한 문의나 불만이 있을 경우 책임자에게 연락할 수 있습니다.

제11조 (개인정보처리방침의 변경)
본 개인정보처리방침은 법령, 정책 또는 서비스의 필요에 따라 변경될 수 있습니다. 중요한 변경사항이 있는 경우 서비스를 통해 이용자에게 공지합니다.

시행일: 본 개인정보처리방침은 이용자 등록일부터 시행됩니다.''';
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

  static String termsAndPrivacy(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Terms of Service / Privacy Policy';
      case 'ja':
        return '利用規約 / プライバシーポリシー';
      default:
        return '이용약관 / 개인정보';
    }
  }

  static String termsTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Terms of Service';
      case 'ja':
        return '利用規約';
      default:
        return '이용약관';
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

  // 템플릿 이름
  static String templateName(Locale locale, String templateId) {
    // 템플릿 이름을 로컬라이즈
    switch (templateId) {
      case 'neon_grid':
        switch (locale.languageCode) {
          case 'en':
            return 'Neon Grid';
          case 'ja':
            return 'ネオングリッド';
          default:
            return '네온 그리드';
        }
      case 'retro_paper':
        switch (locale.languageCode) {
          case 'en':
            return 'Retro Paper';
          case 'ja':
            return 'レトロペーパー';
          default:
            return '레트로 페이퍼';
        }
      case 'mint_terminal':
        switch (locale.languageCode) {
          case 'en':
            return 'Mint Terminal';
          case 'ja':
            return 'ミントターミナル';
          default:
            return '민트 터미널';
        }
      case 'holo_purple':
        switch (locale.languageCode) {
          case 'en':
            return 'Holo Purple';
          case 'ja':
            return 'ホロパープル';
          default:
            return '홀로 퍼플';
        }
      case 'pixel_blue':
        switch (locale.languageCode) {
          case 'en':
            return 'Pixel Blue';
          case 'ja':
            return 'ピクセルブルー';
          default:
            return '픽셀 블루';
        }
      case 'sunset_grid':
        switch (locale.languageCode) {
          case 'en':
            return 'Sunset Grid';
          case 'ja':
            return 'サンセットグリッド';
          default:
            return '선셋 그리드';
        }
      case 'cyber_green':
        switch (locale.languageCode) {
          case 'en':
            return 'Cyber Green';
          case 'ja':
            return 'サイバーグリーン';
          default:
            return '사이버 그린';
        }
      case 'matrix_dark':
        switch (locale.languageCode) {
          case 'en':
            return 'Matrix Dark';
          case 'ja':
            return 'マトリックスダーク';
          default:
            return '매트릭스 다크';
        }
      case 'neon_pink':
        switch (locale.languageCode) {
          case 'en':
            return 'Neon Pink';
          case 'ja':
            return 'ネオンピンク';
          default:
            return '네온 핑크';
        }
      case 'retro_yellow':
        switch (locale.languageCode) {
          case 'en':
            return 'Retro Yellow';
          case 'ja':
            return 'レトロイエロー';
          default:
            return '레트로 옐로우';
        }
      case 'ocean_deep':
        switch (locale.languageCode) {
          case 'en':
            return 'Ocean Deep';
          case 'ja':
            return 'オーシャンディープ';
          default:
            return '오션 딥';
        }
      case 'lavender_night':
        switch (locale.languageCode) {
          case 'en':
            return 'Lavender Night';
          case 'ja':
            return 'ラベンダーナイト';
          default:
            return '라벤더 나이트';
        }
      case 'cherry_blossom':
        switch (locale.languageCode) {
          case 'en':
            return 'Cherry Blossom';
          case 'ja':
            return '桜';
          default:
            return '벚꽃';
        }
      case 'midnight_forest':
        switch (locale.languageCode) {
          case 'en':
            return 'Midnight Forest';
          case 'ja':
            return 'ミッドナイトフォレスト';
          default:
            return '미드나잇 포레스트';
        }
      case 'royal_purple':
        switch (locale.languageCode) {
          case 'en':
            return 'Royal Purple';
          case 'ja':
            return 'ロイヤルパープル';
          default:
            return '로얄 퍼플';
        }
      case 'deep_rose':
        switch (locale.languageCode) {
          case 'en':
            return 'Deep Rose';
          case 'ja':
            return 'ディプローズ';
          default:
            return '딥 로즈';
        }
      case 'starry_night':
        switch (locale.languageCode) {
          case 'en':
            return 'Starry Night';
          case 'ja':
            return '星降る夜';
          default:
            return '별이 빛나는 밤';
        }
      case 'emerald_dark':
        switch (locale.languageCode) {
          case 'en':
            return 'Emerald Dark';
          case 'ja':
            return 'エメラルドダーク';
          default:
            return '에메랄드 다크';
        }
      case 'sapphire_blue':
        switch (locale.languageCode) {
          case 'en':
            return 'Sapphire Blue';
          case 'ja':
            return 'サファイアブルー';
          default:
            return '사파이어 블루';
        }
      case 'crimson_night':
        switch (locale.languageCode) {
          case 'en':
            return 'Crimson Night';
          case 'ja':
            return 'クリムゾンナイト';
          default:
            return '크림슨 나이트';
        }
      default:
        return templateId;
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

  static String nicknamePlaceholder(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'NeonGuide';
      case 'ja':
        return 'ネオンガイド';
      default:
        return '네온길잡이';
    }
  }

  static String passwordPlaceholder(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '••••••••';
      case 'ja':
        return '••••••••';
      default:
        return '••••••••';
    }
  }

  static String friendDeleteFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to delete friend.';
      case 'ja':
        return '友達の削除に失敗しました。';
      default:
        return '친구 삭제에 실패했습니다.';
    }
  }

  static String downloadTimeout(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Download timeout';
      case 'ja':
        return 'ダウンロードタイムアウト';
      default:
        return '다운로드 시간 초과';
    }
  }

  static String imageDownloadFailed(Locale locale, int statusCode) {
    switch (locale.languageCode) {
      case 'en':
        return 'Image download failed: HTTP $statusCode';
      case 'ja':
        return '画像のダウンロードに失敗しました: HTTP $statusCode';
      default:
        return '이미지 다운로드 실패: HTTP $statusCode';
    }
  }

  static String tempFileCreationFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to create temporary file';
      case 'ja':
        return '一時ファイルの作成に失敗しました';
      default:
        return '임시 파일 생성 실패';
    }
  }

  // 예약전송 관련
  static String scheduledLetterNotAvailable(Locale locale, DateTime scheduledAt) {
    final now = DateTime.now();
    final diff = scheduledAt.difference(now);
    
    String timeStr;
    if (diff.inDays > 0) {
      timeStr = '${diff.inDays}일';
    } else if (diff.inHours > 0) {
      timeStr = '${diff.inHours}시간';
    } else if (diff.inMinutes > 0) {
      timeStr = '${diff.inMinutes}분';
    } else {
      timeStr = '곧';
    }
    
    switch (locale.languageCode) {
      case 'en':
        return 'This letter is scheduled to be sent in $timeStr. You cannot view it until the scheduled time.';
      case 'ja':
        return 'この手紙は$timeStr後に送信予定です。予定時刻まで閲覧できません。';
      default:
        return '이 편지는 $timeStr 후에 전송 예정입니다. 예약 시간 전까지는 열람할 수 없습니다.';
    }
  }

  /// 예약전송 편지 팝업 제목
  static String scheduledLetterDialogTitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Scheduled Letter';
      case 'ja':
        return '予約送信の手紙';
      default:
        return '예약전송 편지';
    }
  }

  /// 예약전송 편지 팝업 메시지 (시간 포함)
  static String scheduledLetterDialogMessage(Locale locale, DateTime scheduledAt) {
    final now = DateTime.now();
    final diff = scheduledAt.difference(now);
    
    String timeStr;
    if (diff.inDays > 0) {
      timeStr = '${diff.inDays}일';
    } else if (diff.inHours > 0) {
      timeStr = '${diff.inHours}시간';
    } else if (diff.inMinutes > 0) {
      timeStr = '${diff.inMinutes}분';
    } else {
      timeStr = '곧';
    }
    
    // 날짜/시간 포맷팅
    String dateTimeStr;
    switch (locale.languageCode) {
      case 'en':
        dateTimeStr = '${scheduledAt.year}-${scheduledAt.month.toString().padLeft(2, '0')}-${scheduledAt.day.toString().padLeft(2, '0')} ${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';
        break;
      case 'ja':
        dateTimeStr = '${scheduledAt.year}年${scheduledAt.month}月${scheduledAt.day}日 ${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';
        break;
      default:
        dateTimeStr = '${scheduledAt.year}년 ${scheduledAt.month}월 ${scheduledAt.day}일 ${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';
    }
    
    switch (locale.languageCode) {
      case 'en':
        return 'This letter is scheduled to be sent at $dateTimeStr.\n\nYou can read it after $timeStr.';
      case 'ja':
        return 'この手紙は$dateTimeStrに送信予定です。\n\n$timeStr後に閲覧できます。';
      default:
        return '이 편지는 $dateTimeStr에 전송 예정입니다.\n\n$timeStr 후에 열람할 수 있습니다.';
    }
  }

  static String scheduledLetterOnlyForFriends(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Scheduled sending is only available for friends.';
      case 'ja':
        return '予約送信は友達にのみ利用できます。';
      default:
        return '예약전송은 친구에게만 보낼 수 있습니다.';
    }
  }

  // 차단 관련 문자열
  static String blockUser(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Block User';
      case 'ja':
        return 'ユーザーをブロック';
      default:
        return '사용자 차단';
    }
  }

  static String blockUserConfirm(Locale locale, String nickname) {
    switch (locale.languageCode) {
      case 'en':
        return 'Are you sure you want to block $nickname?\n\nBlocking will remove the friend relationship and hide their public letters.';
      case 'ja':
        return '$nicknameをブロックしてもよろしいですか？\n\nブロックすると友達関係が解除され、公開手紙が非表示になります。';
      default:
        return '$nickname님을 차단하시겠습니까?\n\n차단하면 친구 관계가 끊기고 공개 편지를 볼 수 없게 됩니다.';
    }
  }

  static String block(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Block';
      case 'ja':
        return 'ブロック';
      default:
        return '차단';
    }
  }

  static String userBlocked(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'User blocked';
      case 'ja':
        return 'ユーザーをブロックしました';
      default:
        return '사용자를 차단했습니다';
    }
  }

  static String userBlockedMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'The user has been blocked. You will no longer see their public letters.';
      case 'ja':
        return 'ユーザーをブロックしました。今後、公開手紙は表示されません。';
      default:
        return '사용자를 차단했습니다. 이제 공개 편지를 볼 수 없습니다.';
    }
  }

  static String blockFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to block user';
      case 'ja':
        return 'ブロックに失敗しました';
      default:
        return '차단에 실패했습니다';
    }
  }

  static String unblock(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Unblock';
      case 'ja':
        return 'ブロック解除';
      default:
        return '차단 해제';
    }
  }

  static String unblockConfirm(Locale locale, String nickname) {
    switch (locale.languageCode) {
      case 'en':
        return 'Are you sure you want to unblock $nickname?\n\nNote: You will need to add them as a friend again to exchange letters.';
      case 'ja':
        return '$nicknameのブロックを解除しますか？\n\n注意：手紙をやり取りするには、再度友達追加が必要です。';
      default:
        return '$nickname님의 차단을 해제하시겠습니까?\n\n참고: 편지를 주고받으려면 다시 친구 추가를 해야 합니다.';
    }
  }

  static String userUnblocked(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'User unblocked';
      case 'ja':
        return 'ブロックを解除しました';
      default:
        return '차단을 해제했습니다';
    }
  }

  static String userUnblockedMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'The user has been unblocked. You can now see their public letters again.';
      case 'ja':
        return 'ブロックを解除しました。今後、公開手紙が表示されます。';
      default:
        return '차단을 해제했습니다. 이제 공개 편지를 볼 수 있습니다.';
    }
  }

  static String unblockFailed(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to unblock user';
      case 'ja':
        return 'ブロック解除に失敗しました';
      default:
        return '차단 해제에 실패했습니다';
    }
  }

  static String blockedUsers(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Blocked Users';
      case 'ja':
        return 'ブロックしたユーザー';
      default:
        return '차단한 사용자';
    }
  }

  static String blockedUsersEmpty(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'No blocked users';
      case 'ja':
        return 'ブロックしたユーザーはいません';
      default:
        return '차단한 사용자가 없습니다';
    }
  }

  static String blockedUsersEmptySubtitle(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Users you block will appear here';
      case 'ja':
        return 'ブロックしたユーザーがここに表示されます';
      default:
        return '차단한 사용자가 여기에 표시됩니다';
    }
  }

  static String blockedAt(Locale locale, DateTime blockedAt) {
    final diff = DateTime.now().difference(blockedAt);
    
    if (diff.inDays > 0) {
      switch (locale.languageCode) {
        case 'en':
          return 'Blocked ${diff.inDays} days ago';
        case 'ja':
          return '${diff.inDays}日前にブロック';
        default:
          return '${diff.inDays}일 전 차단';
      }
    } else if (diff.inHours > 0) {
      switch (locale.languageCode) {
        case 'en':
          return 'Blocked ${diff.inHours} hours ago';
        case 'ja':
          return '${diff.inHours}時間前にブロック';
        default:
          return '${diff.inHours}시간 전 차단';
      }
    } else {
      switch (locale.languageCode) {
        case 'en':
          return 'Blocked recently';
        case 'ja':
          return '最近ブロック';
        default:
          return '최근 차단';
      }
    }
  }

  static String cannotBlockSelf(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'You cannot block yourself';
      case 'ja':
        return '自分をブロックすることはできません';
      default:
        return '자신을 차단할 수 없습니다';
    }
  }

  static String alreadyBlocked(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'This user is already blocked';
      case 'ja':
        return 'このユーザーは既にブロックされています';
      default:
        return '이미 차단한 사용자입니다';
    }
  }

  static String blockAndReport(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Block & Report';
      case 'ja':
        return 'ブロック＆報告';
      default:
        return '차단 및 신고';
    }
  }

  // 페이지네이션 - 더 이상 씨앗이 없을 때
  static String noMoreSeeds(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'No more seeds';
      case 'ja':
        return 'これ以上の種はありません';
      default:
        return '더 이상 씨앗이 없어요';
    }
  }
}

