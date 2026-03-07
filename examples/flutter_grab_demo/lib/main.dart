import 'package:flutter/material.dart';
import 'package:flutter_grab/flutter_grab.dart';

void main() {
  runApp(
    FlutterGrab.wrap(config: const FlutterGrabConfig(), child: const DemoApp()),
  );
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_grab_demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        useMaterial3: true,
      ),
      routes: <String, WidgetBuilder>{
        '/': (_) => const DashboardScreen(),
        '/compose': (_) => const ComposeScreen(),
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Grab Demo'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/compose'),
            icon: const Icon(Icons.edit_note),
            label: const Text('Compose'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          FlutterGrabTag(
            name: 'hero-card',
            description: 'Primary value proposition card on the dashboard.',
            tags: const <String>['marketing', 'homepage', 'priority'],
            notes: 'Keep the message direct and the visual hierarchy strong.',
            child: _HeroCard(),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Expanded(
                child: _MetricCard(title: 'Captured today', value: '18'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _MetricCard(title: 'Ready to copy', value: '7'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _MetricCard(title: 'Bridge syncs', value: '12'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FlutterGrabTag(
            name: 'activity-list',
            description:
                'Recent activity feed for validation and empty-state work.',
            tags: const <String>['list', 'content'],
            child: const _ActivityPanel(),
          ),
        ],
      ),
    );
  }
}

class ComposeScreen extends StatelessWidget {
  const ComposeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compose capture request')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FlutterGrabTag(
              name: 'compose-form',
              description:
                  'Editable form layout with labels, helper text, and CTA.',
              tags: const <String>['form', 'editor'],
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Create a guided UI change request',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Use the inspector to grab context from this form, then copy it into Codex with one click.',
                      ),
                      const SizedBox(height: 24),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'Improve the capture panel hierarchy',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const TextField(
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Context',
                          hintText:
                              'Explain the problem, desired outcome, and constraints.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        value: true,
                        onChanged: (_) {},
                        title: const Text('Include bridge export'),
                        subtitle: const Text(
                          'Write the latest JSON capture for local tooling.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.send),
                        label: const Text('Create request'),
                      ),
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

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey<String>('hero-card'),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Design faster with Codex',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Capture widget context, copy it as a prompt, and keep your UI editing loop tight across Flutter desktop, mobile, and web debug builds.',
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Start inspecting'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Container(
              width: 180,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF0F766E), Color(0xFF2563EB)],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.screenshot_monitor,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              'Recent activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 16),
            _ActivityRow(
              title: 'Hero card refined',
              subtitle: 'Copied a context block for a spacing update.',
            ),
            Divider(),
            _ActivityRow(
              title: 'Compose form exported',
              subtitle:
                  'Wrote a fresh JSON capture into .dart_tool/flutter_grab.',
            ),
            Divider(),
            _ActivityRow(
              title: 'Bridge verified',
              subtitle: 'flutter_grab_bridge doctor confirmed expected files.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.bolt)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
