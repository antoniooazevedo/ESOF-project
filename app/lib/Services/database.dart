import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:study_buddy_app/Services/auth.dart';
import 'package:study_buddy_app/Services/user_setting.dart';
import 'package:study_buddy_app/components/sessions.dart';
import 'package:study_buddy_app/components/shop_items.dart';
import 'package:table_calendar/table_calendar.dart';

class DatabaseService {
  final AuthService _authService = AuthService();

  Future<void> importShop() async {
    try {
      final data = {
        'Basil': {
          'image': 'Manjerico.png',
          'coins': 0,
          'xp': 0,
          'name': 'Basil',
          'sizeX': 100.01,
          'sizeY': 100.01,
          'posX': 0.05,
          'posY': 0.12,
        },
        'Food Bowl': {
          'image': 'Food_Bowl.png',
          'coins': 30,
          'xp': 15,
          'name': 'Food Bowl',
          'sizeX': 100.0001,
          'sizeY': 62.0001,
          'posX': 0.05,
          'posY': 0.12,
        },
        'Aquarium': {
          'image': 'Aquarium.png',
          'coins': 0,
          'xp': 0,
          'name': 'Aquarium',
          'sizeX': 100.0001,
          'sizeY': 79.0001,
          'posX': 0.06,
          'posY': 0.12,
        },
        'Basket': {
          'image': 'basket.png',
          'coins': 0,
          'xp': 0,
          'name': 'Basket',
          'sizeX': 100.0001,
          'sizeY': 70.0001,
          'posX': 0.07,
          'posY': 0.12,
        },
        'Fireplace': {
          'image': 'fireplace.png',
          'coins': 0,
          'xp': 0,
          'name': 'Fireplace',
          'sizeX': 100.0001,
          'sizeY': 130.0001,
          'posX': 0.08,
          'posY': 0.12,
        },
        'GameSquare': {
          'image': 'GameSquare.png',
          'coins': 0,
          'xp': 0,
          'name': 'GameSquare',
          'sizeX': 100.0001,
          'sizeY': 85.0001,
          'posX': 0.09,
          'posY': 0.12,
        },
        'Puff': {
          'image': 'Puff.png',
          'coins': 0,
          'xp': 0,
          'name': 'Puff',
          'sizeX': 100.0001,
          'sizeY': 98.0001,
          'posX': 0.1,
          'posY': 0.12,
        },
        'Shovel': {
          'image': 'Shovel.png',
          'coins': 0,
          'xp': 0,
          'name': 'Shovel',
          'sizeX': 100.0001,
          'sizeY': 252.0001,
          'posX': 0.12,
          'posY': 0.12,
        },
        'Stone': {
          'image': 'stone.png',
          'coins': 0,
          'xp': 0,
          'name': 'Stone',
          'sizeX': 100.0001,
          'sizeY': 62.0001,
          'posX': 0.05,
          'posY': 0.12,
        },
        'TV': {
          'image': 'tv.png',
          'coins': 0,
          'xp': 0,
          'name': 'TV',
          'sizeX': 100.0001,
          'sizeY': 123.0001,
          'posX': 0.13,
          'posY': 0.12,
        },
        'Watering Can': {
          'image': 'wateringCan.png',
          'coins': 0,
          'xp': 0,
          'name': 'Watering Can',
          'sizeX': 100.0001,
          'sizeY': 67.0001,
          'posX': 0.13,
          'posY': 0.12,
        },
      };
      FirebaseDatabase.instance.ref().child('Shop').set(data);
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  Future<void> importData() async {
    try {
      final user = _authService.getCurrentUser();
      if (await checkKeyExistence(user!.uid)) {
        print('Node already exists with UID: ${user.uid}');
        return;
      }
      final data = {
        'email': user.email,
        'xp': 1,
        'level': 1,
        'coins': 0,
        'streak': 1,
        'buddy': 0,
        'lastLogIn': DateTime.now().day.toString() +
            '/' +
            DateTime.now().month.toString() +
            '/' +
            DateTime.now().year.toString(),
        'purchased': {
          'Basil': {
            'image': 'Manjerico.png',
            'coins': 0,
            'xp': 0,
            'name': 'Basil',
            'used': false,
            'sizeX': 100.01,
            'sizeY': 100.01,
            'posX': 0.05,
            'posY': 0.12,
          },
        },
      };
      FirebaseDatabase.instance.ref().child("Users").child(user.uid).set(data);
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  Future<int?> getStreak() async {
    try {
      final userId = _authService.getCurrentUser()!.uid;
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('Users/$userId/streak').get();
      final streak = snapshot.value as int?;
      return streak;
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> updateStreak(int streak) async {
    try {
      final uid = _authService.getCurrentUser()!.uid;
      DatabaseReference streakRef =
          FirebaseDatabase.instance.ref().child("Users").child(uid);
      await streakRef.update({"streak": streak});
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  Future<List<Session>> loadSessions() async {
    List<Session> sessions = [];

    if (await checkSessionExistence()) {
      final ref = FirebaseDatabase.instance.ref();
      final uid = _authService.getCurrentUser()!.uid;
      final snapshot = await ref.child('Users/$uid/sessions').get();
      final items = snapshot.value as Map<dynamic, dynamic>;

      items.forEach((key, value) {
        final itemData = value as Map<dynamic, dynamic>;

        sessions.add(
          Session(
            hour: itemData['hour'],
            day: itemData['day'],
            duration: itemData['duration'],
            minute: itemData['minute'],
            month: itemData['month'],
            seconds: itemData['seconds'],
            year: itemData['year'],
          ),
        );
      });

      sessions.sort((a, b) {
        final dateA = DateTime(
          int.parse(a.year),
          int.parse(a.month),
          int.parse(a.day),
          int.parse(a.hour),
          int.parse(a.minute),
          int.parse(a.seconds),
        );

        final dateB = DateTime(
          int.parse(b.year),
          int.parse(b.month),
          int.parse(b.day),
          int.parse(b.hour),
          int.parse(b.minute),
          int.parse(b.seconds),
        );

        return dateA.compareTo(dateB);
      });
    }

    return sessions;
  }

  Future<void> setLastSession() async {
    try {
      final uid = _authService.getCurrentUser()!.uid;
      DatabaseReference sessionsRef = FirebaseDatabase.instance
          .ref()
          .child("Users")
          .child(uid)
          .child('sessions');
      final now = DateTime.now();
      final session = Session(
          hour: now.hour.toString(),
          day: now.day.toString(),
          duration: UserSettings.duration.toString(),
          minute: now.minute.toString(),
          month: now.month.toString(),
          year: now.year.toString(),
          seconds: now.second.toString());
      await sessionsRef.push().set({
        'hour': session.hour,
        'day': session.day,
        'duration': session.duration,
        'minute': session.minute,
        'month': session.month,
        'year': session.year,
        'seconds': session.seconds,
      });
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  Future<List<ShopItem>> getShop() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('Shop').get();
    final items = snapshot.value as Map<dynamic, dynamic>;
    List<ShopItem> shop = [];

    items.forEach((key, value) {
      final itemData = value as Map<dynamic, dynamic>;
      shop.add(
        ShopItem(
          image: itemData['image'],
          coins: itemData['coins'],
          xp: itemData['xp'],
          name: itemData['name'],
          sizeX: itemData['sizeX'],
          sizeY: itemData['sizeY'],
          posX: itemData['posX'],
          posY: itemData['posY'],
        ),
      );
    });

    shop.sort((a, b) => a.xp.compareTo(b.xp));
    return shop;
  }

  Future<List<ShopItem>> getPurchases() async {
    final user = _authService.getCurrentUser()?.uid;
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('Users/$user/purchased').get();
    final items = snapshot.value as Map<dynamic, dynamic>;
    List<ShopItem> purchases = [];

    items.forEach((key, value) {
      final itemData = value as Map<dynamic, dynamic>;
      purchases.add(
        ShopItem(
          image: itemData['image'],
          coins: itemData['coins'],
          xp: itemData['xp'],
          name: itemData['name'],
          sizeX: itemData['sizeX'],
          sizeY: itemData['sizeY'],
          posX: itemData['posX'],
          posY: itemData['posY'],
          used: itemData['used'],
        ),
      );
    });

    return purchases;
  }

  Future<void> updatePurchases(List<ShopItem> purchases) async {
    try {
      final user = _authService.getCurrentUser()?.uid;
      final ref =
          FirebaseDatabase.instance.ref().child('Users/$user/purchased');

      for (int i = 0; i < purchases.length; i++) {
        final item = purchases[i];
        await ref.child(item.name).set({
          'image': item.image,
          'coins': item.coins,
          'xp': item.xp,
          'name': item.name,
          'sizeX': item.sizeX,
          'sizeY': item.sizeY,
          'posX': item.posX,
          'posY': item.posY,
          'used': item.used,
        });
      }
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  Future<bool> checkSessionExistence() async {
    try {
      final user = _authService.getCurrentUser();
      DatabaseReference reference = FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(user!.uid)
          .child("sessions");
      DatabaseEvent snapshot = (await reference.once());
      return snapshot.snapshot.value != null;
    } on FirebaseException catch (e) {
      print(e);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> checkKeyExistence(String key) async {
    try {
      final user = _authService.getCurrentUser();
      DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('Users').child(user!.uid);
      DatabaseEvent snapshot = (await reference.once());
      return snapshot.snapshot.value != null;
    } on FirebaseException catch (e) {
      print(e);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> checkItemExistence(String key) async {
    try {
      final user = _authService.getCurrentUser();
      DatabaseReference reference = FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(user!.uid)
          .child('purchased')
          .child(key);
      DatabaseEvent snapshot = (await reference.once());
      return snapshot.snapshot.value != null;
    } on FirebaseException catch (e) {
      print(e);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<int?> getBuddy() async {
    try {
      final userId = _authService.getCurrentUser()!.uid;
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('Users/$userId/buddy').get();
      final buddy = snapshot.value as int?;
      return buddy;
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> updateBuddy(int choice) async {
    try {
      final uid = _authService.getCurrentUser()!.uid;
      DatabaseReference buddyRef =
          FirebaseDatabase.instance.ref().child("Users").child(uid);
      await buddyRef.update({"buddy": choice});
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  Future<int?> getXp() async {
    try {
      final userId = _authService.getCurrentUser()!.uid;
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('Users/$userId/xp').get();
      final xpValue = snapshot.value as int?;
      return xpValue;
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<int?> getCoins() async {
    try {
      final userId = _authService.getCurrentUser()!.uid;
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('Users/$userId/coins').get();
      final coins = snapshot.value as int?;
      return coins;
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> updateCoins(int coins) async {
    try {
      final uid = _authService.getCurrentUser()!.uid;
      DatabaseReference xpRef =
          FirebaseDatabase.instance.ref().child("Users").child(uid);
      await xpRef.update({"coins": coins});
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  Future<int?> getLevel() async {
    try {
      final userId = _authService.getCurrentUser()!.uid;
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('Users/$userId/level').get();
      final level = snapshot.value as int?;
      return level;
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<int> getLvl(int xp) async {
    int level =
        min(20, (log(xp) / log(pow(e, ((log(44640)) / 19)))).floor() + 1);
    return level;
  }

  Future<void> updateXp(int xp) async {
    try {
      final uid = _authService.getCurrentUser()!.uid;
      DatabaseReference xpRef =
          FirebaseDatabase.instance.ref().child("Users").child(uid);
      await xpRef.update({"xp": xp});
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateLevel(int lvl) async {
    try {
      final uid = _authService.getCurrentUser()!.uid;
      DatabaseReference xpRef =
          FirebaseDatabase.instance.ref().child("Users").child(uid);
      await xpRef.update({"level": lvl});
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  int getNextLvlXp(int lvl) {
    int xp = pow(e, ((log(44640) * (lvl)) / 19)).floor();
    return xp;
  }

  Future<void> updateLastLogin(String date) async {
    try {
      final uid = _authService.getCurrentUser()!.uid;
      DatabaseReference xpRef =
          FirebaseDatabase.instance.ref().child("Users").child(uid);
      await xpRef.update({"lastLogIn": date});
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  Future<String> getLastLogIn() async {
    try {
      final userId = _authService.getCurrentUser()!.uid;
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('Users/$userId/lastLogIn').get();
      final date = snapshot.value;
      return date.toString();
    } on FirebaseException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    return "";
  }

  Future<void> buildData() async {
    UserSettings settings = UserSettings();
    settings.clearUserSettings();
    int lvl = await getLvl((await getXp())!);
    updateLevel(lvl);
    UserSettings.level = lvl;
    UserSettings.xpAmount = (await getXp())!;
    UserSettings.coinsAmount = (await getCoins())!;
    UserSettings.buddy = (await getBuddy())!;
    UserSettings.purchased = (await getPurchases());
    UserSettings.shop = (await getShop());
    UserSettings.sessions = (await loadSessions());
    UserSettings.streak = (await getStreak())!;
    UserSettings.lastLogIn = (await getLastLogIn());
    Future.delayed(Duration(seconds: 1));
  }

  Future<void> streakBuild() async {
    int length = UserSettings.sessions.length;
    List<Session> sessions = UserSettings.sessions;
    bool duration = false;
    if (sessions.isNotEmpty) {
      if (int.parse(sessions[length - 1].duration) > 1800) {
        duration = true;
      }
    }

    late DateTime lastDay;

    DateTime today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    if(sessions.isNotEmpty){
      lastDay = DateTime(
          int.parse(sessions[length - 1].year),
          int.parse(sessions[length - 1].month),
          int.parse(sessions[length - 1].day));
    }

    if (duration && sessions.isNotEmpty &&
        (UserSettings.lastLogIn != (lastDay.toString()))) {
      bool streakUpdate = (!isSameDay(today, lastDay) && today.difference(lastDay).inDays == 1);
      if (streakUpdate) {
        if (UserSettings.streak < 7) {
          UserSettings.streak++;
          updateStreak(UserSettings.streak);
          switch (UserSettings.streak) {
            case 1:
              UserSettings.multiplier = 1;
              break;
            case 2:
              UserSettings.multiplier = 1.17;
              break;
            case 3:
              UserSettings.multiplier = 1.34;
              break;
            case 4:
              UserSettings.multiplier = 1.51;
              break;
            case 5:
              UserSettings.multiplier = 1.68;
              break;
            case 6:
              UserSettings.multiplier = 1.85;
              break;
            case 7:
              UserSettings.multiplier = 2;
              break;
          }
        } else {
          UserSettings.streak++;
          updateStreak(UserSettings.streak);
          UserSettings.multiplier = 2;
        }
      } else {
        UserSettings.streak = 1;
        UserSettings.multiplier = 1;
        updateStreak(UserSettings.streak);
      }
    }
  }
}
