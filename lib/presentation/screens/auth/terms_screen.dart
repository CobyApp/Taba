import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이용약관 / 개인정보'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.10)),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientGalaxy,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(90),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Taba 이용약관', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      Text('본 약관은 서비스 이용과 관련하여... (샘플 텍스트)'),
                      SizedBox(height: 16),
                      Text('개인정보 처리방침', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      Text('당사는 서비스 제공을 위해 최소한의 개인정보를 수집하며... (샘플 텍스트)'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TermsContent extends StatelessWidget {
  const TermsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('이용약관 / 개인정보', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(60),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(maxHeight: 420),
              child: const SingleChildScrollView(
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.white70, height: 1.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Taba 이용약관', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      Text('본 약관은 서비스 이용과 관련하여... (샘플 텍스트)'),
                      SizedBox(height: 16),
                      Text('개인정보 처리방침', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      Text('당사는 서비스 제공을 위해 최소한의 개인정보를 수집하며... (샘플 텍스트)'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsOnlyContent extends StatefulWidget {
  const TermsOnlyContent({super.key});

  @override
  State<TermsOnlyContent> createState() => _TermsOnlyContentState();
}

class _TermsOnlyContentState extends State<TermsOnlyContent> {
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('이용약관', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(60),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(maxHeight: 420),
              child: const SingleChildScrollView(
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.white70, height: 1.5),
                  child: Text('본 약관은 서비스 이용과 관련하여... (샘플 텍스트)'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _agree,
              onChanged: (v) => setState(() => _agree = v ?? false),
              title: const Text('이용약관에 동의합니다.'),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agree ? () => Navigator.of(context).pop(true) : null,
                child: const Text('동의하고 닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyOnlyContent extends StatefulWidget {
  const PrivacyOnlyContent({super.key});

  @override
  State<PrivacyOnlyContent> createState() => _PrivacyOnlyContentState();
}

class _PrivacyOnlyContentState extends State<PrivacyOnlyContent> {
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('개인정보 처리방침', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(60),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(maxHeight: 420),
              child: const SingleChildScrollView(
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.white70, height: 1.5),
                  child: Text('당사는 서비스 제공을 위해 최소한의 개인정보를 수집하며... (샘플 텍스트)'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _agree,
              onChanged: (v) => setState(() => _agree = v ?? false),
              title: const Text('개인정보 처리방침에 동의합니다.'),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agree ? () => Navigator.of(context).pop(true) : null,
                child: const Text('동의하고 닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


