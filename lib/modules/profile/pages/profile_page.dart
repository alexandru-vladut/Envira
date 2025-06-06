import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets.dart';
import 'package:flutter_app_base/modules/profile/providers/profile_provider.dart';
import 'package:flutter_app_base/modules/profile/utils/assets.dart';
import 'package:flutter_app_base/modules/profile/utils/iconly_bold.dart';
import 'package:flutter_app_base/modules/profile/utils/repository.dart';
import 'package:flutter_app_base/modules/profile/utils/shortcut_list.dart';
import 'package:flutter_app_base/modules/profile/widgets/custom_list_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return ProfileProvider(
      builder: (data) =>
        Scaffold(
          backgroundColor: Repository.bgColor(context),
          body: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              const SizedBox(height: 40),
              Stack(
                children: [
                  Container(
                    height: 280,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 230,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Repository.accentColor(context),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Center(
                            child: Text(
                              (data.currentUser != null) ? data.currentUser!.name : '',
                              style: TextStyle(
                                color: Repository.textColor(context),
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            (data.currentUser != null) ? data.currentUser!.email : '',
                            style: TextStyle(
                              color: Repository.subTextColor(context),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: profilesShortcutList.map<Widget>((e) {
                              return GestureDetector(
                                onTap: () => confirmDialog(
                                  title: "Are you sure you want to log out?",
                                  onConfirm: () async => await authService.logOut(),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 15),
                                  padding: const EdgeInsets.all(13),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Icon(e['icon'], color: e['color']),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    right: 30,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE486DD),
                      ),
                      child: Transform.scale(
                        scale: 0.55,
                        child: Image.asset(Assets.memoji6),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 50),
              CustomListTile(
                  icon: Icons.handshake,
                  color: const Color.fromARGB(255, 201, 0, 71),
                  title: 'Terms and Conditions', context: context),
              const SizedBox(height: 10),
              CustomListTile(
                  icon: IconlyBold.Shield_Done,
                  color: const Color(0xFF229e76),
                  title: 'Security', context: context),
              const SizedBox(height: 10),
              CustomListTile(
                  icon: IconlyBold.Message,
                  color: const Color(0xFFe17a0a),
                  title: 'Contact us', context: context),
              const SizedBox(height: 10),
              CustomListTile(
                  icon: IconlyBold.Document,
                  color: const Color(0xFF064c6d),
                  title: 'Support', context: context),
            ],
          ),
        ),
    );
  }
}

