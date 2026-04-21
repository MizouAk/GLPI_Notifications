import 'package:flutter/material.dart';
import 'package:mobile_app/models/app_models.dart';
import 'package:mobile_app/widgets/common.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key, required this.templates});
  final List<NotificationTemplate> templates;

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  int active = 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.templates[active];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Admin · Content', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text('Notification Templates', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SurfaceCard(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(widget.templates.length, (index) {
                final t = widget.templates[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t.name),
                    selected: active == index,
                    onSelected: (_) => setState(() => active = index),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Editor', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: item.subject),
                decoration: const InputDecoration(labelText: 'Subject'),
                onChanged: (value) => item.subject = value,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: item.body),
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Body'),
                onChanged: (value) => item.body = value,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Live preview', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Subject: ${item.subject}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(item.body),
            ],
          ),
        ),
      ],
    );
  }
}
