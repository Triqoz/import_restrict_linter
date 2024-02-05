import 'package:analyzer/error/listener.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// This is the entrypoint of our custom linter
PluginBase createPlugin() => ImportRestricterLinter();

/// A plugin class is used to list all the assists/lints defined by a plugin.
class ImportRestricterLinter extends PluginBase {
  /// We list all the custom warnings/infos/errors
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    ImportRestricterLintCode(),
    DataFolderImportLintCode(),
  ];
}

class ImportRestricterLintCode extends DartLintRule {
  ImportRestricterLintCode() : super(code: _code);

  static const _code = LintCode(
    name: 'import_restrict_linter',
    problemMessage: 'Imports containing "/core/" and /ui/ are not allowed.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addImportDirective((node) {
      String importUri = node.uri.stringValue!;
      /// Dont import directly from core and ui anywhere
      /// Dont import core.dart in core
      if (importUri.contains('/core/') || importUri.contains('/ui/')) {
        reporter.reportErrorForNode(_code, node);
      }
    });
  }
}

class DataFolderImportLintCode extends DartLintRule {
  DataFolderImportLintCode() : super(code: _dataFolderImportCode);

  static const _dataFolderImportCode = LintCode(
    name: 'data_folder_ui_import_linter',
    problemMessage: 'Imports within /data/ should not include ui.dart barrel file.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
      CustomLintResolver resolver,
      ErrorReporter reporter,
      CustomLintContext context,
      ) {
    // Check if the current file being linted is in the /data/ folder
    if (resolver.path.contains('/data/')) {
      context.registry.addImportDirective((node) {
        String importUri = node.uri.stringValue!;
        if (importUri.endsWith('/ui.dart')) {
          reporter.reportErrorForNode(_dataFolderImportCode, node);
        }
      });
    }
  }
}