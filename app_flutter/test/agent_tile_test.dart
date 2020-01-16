// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:cocoon_service/protos.dart' show Agent;

import 'package:app_flutter/agent_health_details.dart';
import 'package:app_flutter/agent_list.dart';
import 'package:app_flutter/agent_tile.dart';
import 'package:app_flutter/state/agent.dart';

void main() {
  group('AgentTile', () {
    final Agent agent = Agent()
      ..healthCheckTimestamp =
          Int64.parseInt(DateTime.now().millisecondsSinceEpoch.toString())
      ..isHealthy = true
      ..healthDetails = '''
ssh-connectivity: succeeded
    Last known IP address: 192.168.1.29

android-device-ZY223D6B7B: succeeded
has-healthy-devices: succeeded
    Found 1 healthy devices

cocoon-authentication: succeeded
cocoon-connection: succeeded
able-to-perform-health-check: succeeded''';

    final FullAgent fullAgent = FullAgent(agent, AgentHealthDetails(agent));

    MockAgentState mockAgentState;

    setUp(() {
      mockAgentState = MockAgentState();
    });

    tearDown(() {
      clearInteractions(mockAgentState);
    });

    testWidgets('raw health details dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentTile(
              fullAgent: fullAgent,
            ),
          ),
        ),
      );

      // Open the agent tile menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text(agent.healthDetails), findsNothing);
      expect(find.byType(SimpleDialog), findsNothing);

      expect(find.text('Raw health details'), findsOneWidget);

      await tester.tap(find.text('Raw health details'));
      await tester.pump();

      expect(find.byType(SimpleDialog), findsOneWidget);
      expect(find.text(agent.healthDetails), findsOneWidget);
    });

    testWidgets('authorize agent calls api', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AgentTile(
            fullAgent: fullAgent,
            agentState: mockAgentState,
          ),
        ),
      );

      // open the agent tile menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      verifyNever(mockAgentState.authorizeAgent(any));

      expect(find.text('Authorize agent'), findsOneWidget);

      await tester.tap(find.text('Authorize agent'));
      await tester.pump();

      verify(mockAgentState.authorizeAgent(any)).called(1);
    });

    testWidgets('reserve task calls api', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentTile(
              fullAgent: fullAgent,
              agentState: mockAgentState,
            ),
          ),
        ),
      );

      // open the agent tile menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      verifyNever(mockAgentState.reserveTask(any));

      expect(find.text('Reserve task'), findsOneWidget);

      await tester.tap(find.text('Reserve task'));
      await tester.pump();

      verify(mockAgentState.reserveTask(any)).called(1);
    });

    testWidgets('agent info is shown', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AgentTile(
            fullAgent: fullAgent,
          ),
        ),
      );

      expect(find.byType(AgentHealthDetailsBar), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.byIcon(Icons.device_unknown), findsOneWidget);
    });
  });
}

class MockAgentState extends Mock implements AgentState {}