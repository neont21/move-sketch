import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OSSLicensesPage extends StatefulWidget {
  const OSSLicensesPage({super.key});

  @override
  State<OSSLicensesPage> createState() => _OSSLicensePageState();
}

class _OSSLicensePageState extends State<OSSLicensesPage> {
  final List<Map<String, dynamic>> _ossLicenses = [];
  bool _isLoading = true;

  Future<void> _loadLicenses() async {
    final Map<String, dynamic> packageLicenses = {};

    await for (var license in LicenseRegistry.licenses) {
      String licenseText = license.paragraphs.map((p) => p.text).join('\n\n');

      for (var package in license.packages) {
        if (!packageLicenses.containsKey(package)) {
          packageLicenses[package] = [];
        }
        packageLicenses[package]!.add(licenseText);
      }
    }

    final sortedPackages = packageLicenses.keys.toList()..sort();

    for (final package in sortedPackages) {
      _ossLicenses.add({
        'name': package,
        'licenses': packageLicenses[package]!,
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showBottomSheet(BuildContext context, String package, List licenses) {
    TextTheme textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(package, style: textTheme.bodyLarge),
                Text('라이선스 ${licenses.length}개', style: textTheme.labelMedium),
                Divider(),
                Expanded(
                  child: ListView.separated(
                    itemCount: licenses.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          licenses[index],
                          style: textTheme.labelSmall,
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.chevron_left, color: colorScheme.tertiary),
        ),
        title: Text('오픈소스 라이선스'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _ossLicenses.length,
                itemBuilder: (context, index) {
                  final item = _ossLicenses[index];
                  final String package = item['name'];
                  final List licenses = item['licenses'];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20),
                    ),
                    child: ListTile(
                      title: Text(package, style: textTheme.bodyMedium),
                      subtitle: Text(
                        '라이선스 ${licenses.length}개',
                        style: textTheme.labelMedium,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colorScheme.tertiaryContainer,
                      ),
                      onTap: () => _showBottomSheet(context, package, licenses),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
