import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/poll_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userId});

  final int userId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PollCubit>().loadPolls(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Polls')),
      body: BlocBuilder<PollCubit, PollState>(
        builder: (context, state) {
          if (state is PollLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PollListLoaded) {
            return ListView(
              children: state.polls
                  .map(
                    (e) => ListTile(
                      title: Text(e.question),
                      subtitle: Text('${e.workspaceName} · ${e.category}'),
                      trailing: e.hasVoted
                          ? const Icon(Icons.check_circle_outline)
                          : null,
                    ),
                  )
                  .toList(),
            );
          } else if (state is PollError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
