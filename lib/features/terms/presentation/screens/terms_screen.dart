import 'package:flutter/material.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/features/terms/domain/entities/terms_entity.dart';
import 'package:votera_app/features/terms/domain/repositories/iterms_repository.dart';
import 'package:flutter_html/flutter_html.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({
    super.key,
    required this.terms,
    this.appCode = 'VOTERA',
    this.termsType = 'TNC',
    this.postAcceptArgs,
  });

  final TermsEntity terms;
  final String appCode;
  final String termsType;
  final Object? postAcceptArgs;

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _accepting = false;

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      final repo = sl<ITermsRepository>();
      final res = await repo.accept(
        appCode: widget.appCode,
        termsType: widget.termsType,
        version: widget.terms.version,
      );
      final success = (res['success'] as bool?) ?? false;
      final message =
          res['message']?.toString() ?? 'Unexpected response from server';
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
        return;
      }
      if (mounted) {
        if (widget.postAcceptArgs != null) {
          Navigator.of(context).pushReplacementNamed(
            RouteNames.dashboard,
            arguments: widget.postAcceptArgs,
          );
        } else {
          Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.terms.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Html(data: widget.terms.content),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _accepting ? null : _accept,
                  child: _accepting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Accept'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
