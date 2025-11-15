import 'package:flutter/material.dart';
import 'package:taba_app/data/mock/mock_data.dart';
import 'package:taba_app/presentation/screens/bouquet/bouquet_screen.dart';
import 'package:taba_app/presentation/screens/settings/settings_screen.dart';
import 'package:taba_app/presentation/screens/sky/sky_screen.dart';
import 'package:taba_app/presentation/screens/write/write_letter_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  Widget build(BuildContext context) {
    final repo = MockDataRepository.instance;
    final unreadBouquet = repo.friendBouquets.fold<int>(
      0,
      (value, bouquet) => value + bouquet.unreadCount,
    );
    return Scaffold(
      body: SkyScreen(
        letters: repo.letters,
        notifications: repo.notifications,
        unreadBouquetCount: unreadBouquet,
        onOpenBouquet: () => _openBouquet(context, repo),
        onOpenSettings: () => _openSettings(context, repo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWritePage(context),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('편지 쓰기'),
      ),
    );
  }

  void _openBouquet(BuildContext context, MockDataRepository repo) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BouquetScreen(
          friendBouquets: repo.friendBouquets,
        ),
      ),
    );
  }

  void _openSettings(BuildContext context, MockDataRepository repo) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(currentUser: repo.users.first),
      ),
    );
  }

  void _openWritePage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WriteLetterPage(),
      ),
    );
  }
}

