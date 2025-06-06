import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/models/voucher_model.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/data/providers/vouchers_provider.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:provider/provider.dart';

class VouchersPage extends StatefulWidget {
  const VouchersPage({super.key});

  @override
  State<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> {

  @override
  Widget build(BuildContext context) {
    final currentUserUid = context.select<AuthStateProvider, String?>((auth) => auth.uid);
    final currentUser = context.select<UsersProvider, UserModel?>(
      (provider) => provider.items.firstWhereOrNull((u) => u.uid == currentUserUid),
    );
    final vouchers = context.watch<VouchersProvider>().items;
    
    final myVouchers = vouchers.where((voucher) => 
      currentUser?.myVouchersIds.contains(voucher.docId) ?? false
    ).toList();
    
    final availableVouchers = vouchers.where((voucher) => 
      !(currentUser?.myVouchersIds.contains(voucher.docId) ?? false)
    ).toList();


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Set the background color to transparent
        elevation: 0, // Remove the shadow
        title: Text(
          (currentUser != null) ? 'Vouchers - Credits: ${currentUser.credits}' : 'Vouchers - Credits:',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          
          if (myVouchers.isNotEmpty) ...[
            const Divider(),
            const Text(
              "My Vouchers",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: myVouchers.map((voucher) {
                return voucherListCard(voucher: voucher, isAdded: true, currentUser: currentUser);
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          if (availableVouchers.isNotEmpty) ...[
            const Text(
              "Available Vouchers",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: availableVouchers.map((voucher) {
                return voucherListCard(voucher: voucher, isAdded: false, currentUser: currentUser);
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget voucherListCard({required VoucherModel voucher, required bool isAdded, required UserModel? currentUser}) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      (voucher.partner == 'Altex') ? 'assets/images/altex.png' :
                      (voucher.partner == 'Ivelo') ? 'assets/images/velo.png' :
                      (voucher.partner == 'Tazz') ? 'assets/images/tazz.png' :
                      (voucher.partner == 'Nespresso') ? 'assets/images/nespresso.png' :
                      (voucher.partner == 'Bolt') ? 'assets/images/bolt.png' :
                      'assets/images/logomic.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        voucher.description,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15,),
          Column(
            children: [
              Text(
                voucher.cost.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'Pts',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  if (!isAdded) {
                    await voucherService.purchaseVoucher(context, currentUser, voucher);
                  } else {
                    await voucherService.refundVoucher(context, currentUser, voucher);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAdded ? Colors.red : Colors.green,
                  ),
                  child: Icon(
                    isAdded ? Icons.remove : Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
