// bin/toln.dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:toln/src/cli/extractor.dart';
import 'package:toln/src/cli/syncer.dart';
import 'package:toln/src/cli/auto_applier.dart';

const String commandExtract = 'extract';
const String commandSync = 'sync';
const String commandAutoApply = 'auto-apply';

final ArgParser argParser = ArgParser()
  ..addCommand(commandExtract)
  ..addCommand(commandSync)
  ..addCommand(
      commandAutoApply,
      ArgParser()
        ..addFlag('dry-run',
            negatable: false,
            help:
                'Shows which files would be changed without actually modifying them.'));

void main(List<String> arguments) async {
  try {
    final ArgResults results = argParser.parse(arguments);
    final command = results.command;

    if (command == null) {
      printError(
          'No command specified. Available commands: extract, sync, auto-apply');
      exit(1);
    }

    final projectPath = Directory.current.path;

    switch (command.name) {
      case commandExtract:
        printInfo('Running ToLn Extractor...');
        await Extractor(projectPath).run();
        printSuccess('Extraction complete!');
        break;
      case commandSync:
        printInfo('Running ToLn Syncer...');
        await Syncer(projectPath).run();
        printSuccess('Sync complete!');
        break;
      case commandAutoApply:
        printInfo('Running ToLn Auto-Applier...');
        final dryRun = command['dry-run'] as bool;
        await AutoApplier(projectPath, dryRun: dryRun).run();

        // --- THE NEW WORKFLOW IS HERE! ---
        // If it's not a dry-run, automatically run the extractor afterwards.
        if (!dryRun) {
          printInfo('----------------------------------------------------');
          printInfo('Auto-apply finished. Now running extractor...');
          await Extractor(projectPath).run();
          printSuccess(
              'SUCCESS! Your code is now localized and translation files are ready.');
        } else {
          printSuccess('Auto-apply dry-run finished. No files were changed.');
        }
        break;
    }
  } on FormatException catch (e) {
    printError(e.message);
    print(argParser.usage);
    exit(1);
  } catch (e) {
    printError('An unexpected error occurred: ${e.toString()}');
    exit(1);
  }
}

void printError(String text) => stdout.writeln('\x1B[31m[ERROR] $text\x1B[0m');
void printInfo(String text) => stdout.writeln('\x1B[34m[INFO] $text\x1B[0m');
void printSuccess(String text) =>
    stdout.writeln('\x1B[32m[SUCCESS] $text\x1B[0m');
