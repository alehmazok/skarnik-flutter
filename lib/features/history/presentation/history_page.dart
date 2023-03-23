import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/features/app/presentation/skarnik_app_cubit.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     onPressed: () => context.go('/search'),
        //     icon: const Icon(Icons.search),
        //   ),
        // ],
        // backgroundColor: Colors.grey.shade50,
        // elevation: 0,
        title: SizedBox(
          height: 56,
          child: TextField(
            autofocus: false,
            decoration: const InputDecoration(
              hintText: 'Search words',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(56),
                ),
              ),
            ),
            readOnly: true,
            onTap: () => context.go('/search'),
          ),
        ),
      ),
      body: BlocBuilder<SkarnikAppCubit, SkarnikAppState>(
        builder: (context, state) {
          return ListView();
        },
      ),
    );
  }
}
