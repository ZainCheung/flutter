// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/memory.dart';
import 'package:flutter_tools/src/artifacts.dart';
import 'package:flutter_tools/src/base/config.dart';
import 'package:flutter_tools/src/base/logger.dart';
import 'package:flutter_tools/src/base/platform.dart';
import 'package:flutter_tools/src/build_info.dart';
import 'package:flutter_tools/src/test/web_test_compiler.dart';
import 'package:flutter_tools/src/web/compile.dart';
import 'package:test/expect.dart';

import '../../src/context.dart';

void main() {
  testUsingContext('web test compiler issues valid compile command', () async {
    final logger = BufferLogger.test();
    final fileSystem = MemoryFileSystem.test();
    fileSystem.file('project/test/fake_test.dart').createSync(recursive: true);
    fileSystem.file('build/out').createSync(recursive: true);
    fileSystem.file('build/build/out.sources').createSync(recursive: true);
    fileSystem.file('build/build/out.json')
      ..createSync()
      ..writeAsStringSync('{}');
    fileSystem.file('build/build/out.map').createSync();
    fileSystem.file('build/build/out.metadata').createSync();
    final platform = FakePlatform(environment: <String, String>{});
    final config = Config(
      Config.kFlutterSettings,
      fileSystem: fileSystem,
      logger: logger,
      platform: platform,
    );
    final processManager = FakeProcessManager.list(<FakeCommand>[
      const FakeCommand(
        command: <Pattern>[
          'Artifact.engineDartAotRuntime.TargetPlatform.web_javascript',
          'Artifact.frontendServerSnapshotForEngineDartSdk.TargetPlatform.web_javascript',
          '--sdk-root',
          'HostArtifact.flutterWebSdk/',
          '--incremental',
          '--target=dartdevc',
          '--experimental-emit-debug-metadata',
          '-DFLUTTER_WEB_USE_SKIA=true',
          '-DFLUTTER_WEB_USE_SKWASM=false',
          '--output-dill',
          'build/out',
          '--packages',
          '.dart_tool/package_config.json',
          '-Ddart.vm.profile=false',
          '-Ddart.vm.product=false',
          '--enable-asserts',
          '--filesystem-root',
          'project/test',
          '--filesystem-root',
          'build',
          '--filesystem-scheme',
          'org-dartlang-app',
          '--initialize-from-dill',
          'build/cache.dill',
          '--platform',
          'file:///HostArtifact.webPlatformKernelFolder/ddc_outline.dill',
          '--verbosity=error',
        ],
        stdout: 'result abc\nline0\nline1\nabc\nabc build/out 0',
      ),
    ]);
    final compiler = WebTestCompiler(
      logger: logger,
      fileSystem: fileSystem,
      platform: FakePlatform(environment: <String, String>{}),
      artifacts: Artifacts.test(),
      processManager: processManager,
      config: config,
    );

    const buildInfo = BuildInfo(
      BuildMode.debug,
      '',
      treeShakeIcons: false,
      packageConfigPath: '.dart_tool/package_config.json',
    );

    await compiler.initialize(
      projectDirectory: fileSystem.directory('project'),
      testOutputDir: 'build',
      testFiles: <String>['project/test/fake_test.dart'],
      buildInfo: buildInfo,
      webRenderer: WebRendererMode.canvaskit,
      useWasm: false,
    );

    expect(processManager.hasRemainingExpectations, isFalse);
  });

  testUsingContext('web test compiler issues valid compile command (wasm)', () async {
    final logger = BufferLogger.test();
    final fileSystem = MemoryFileSystem.test();
    fileSystem.file('project/test/fake_test.dart').createSync(recursive: true);
    fileSystem.file('build/out').createSync(recursive: true);
    fileSystem.file('build/build/out.sources').createSync(recursive: true);
    fileSystem.file('build/build/out.json')
      ..createSync()
      ..writeAsStringSync('{}');
    fileSystem.file('build/build/out.map').createSync();
    fileSystem.file('build/build/out.metadata').createSync();
    final platform = FakePlatform(environment: <String, String>{});
    final config = Config(
      Config.kFlutterSettings,
      fileSystem: fileSystem,
      logger: logger,
      platform: platform,
    );
    final processManager = FakeProcessManager.list(<FakeCommand>[
      const FakeCommand(
        command: <Pattern>[
          'Artifact.engineDartBinary.TargetPlatform.web_javascript',
          'compile',
          'wasm',
          '--packages=.dart_tool/package_config.json',
          '--extra-compiler-option=--platform=HostArtifact.webPlatformKernelFolder/dart2wasm_platform.dill',
          '--extra-compiler-option=--multi-root-scheme=org-dartlang-app',
          '--extra-compiler-option=--multi-root=project/test',
          '--extra-compiler-option=--multi-root=build',
          '--extra-compiler-option=--enable-asserts',
          '--extra-compiler-option=--no-inlining',
          '-DFLUTTER_WEB_USE_SKIA=true',
          '-DFLUTTER_WEB_USE_SKWASM=false',
          '-O0',
          '-o',
          'build/main.dart.wasm',
          'build/main.dart',
        ],
        stdout: 'result abc\nline0\nline1\nabc\nabc build/out 0',
      ),
    ]);
    final compiler = WebTestCompiler(
      logger: logger,
      fileSystem: fileSystem,
      platform: FakePlatform(environment: <String, String>{}),
      artifacts: Artifacts.test(),
      processManager: processManager,
      config: config,
    );

    const buildInfo = BuildInfo(
      BuildMode.debug,
      '',
      treeShakeIcons: false,
      packageConfigPath: '.dart_tool/package_config.json',
    );

    await compiler.initialize(
      projectDirectory: fileSystem.directory('project'),
      testOutputDir: 'build',
      testFiles: <String>['project/test/fake_test.dart'],
      buildInfo: buildInfo,
      webRenderer: WebRendererMode.canvaskit,
      useWasm: true,
    );

    expect(processManager.hasRemainingExpectations, isFalse);
  });
}
