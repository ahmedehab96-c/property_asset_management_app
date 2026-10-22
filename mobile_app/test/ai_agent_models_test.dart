import 'package:flutter_test/flutter_test.dart';
import 'package:property_asset_management_app/services/ai_service.dart';

void main() {
  group('AgentMessage.fromJson', () {
    test('maps every action status the server sends', () {
      final message = AgentMessage.fromJson({
        'role': 'assistant',
        'content': 'تم',
        'actions': [
          {'tool': 'search_properties', 'status': 'completed'},
          {
            'tool': 'create_maintenance_request',
            'status': 'pending_confirmation',
          },
          {'tool': 'run_sql', 'status': 'failed'},
          {'tool': 'create_maintenance_request', 'status': 'cancelled'},
        ],
        'pending_action_id': 7,
      });

      expect(message.content, 'تم');
      expect(message.pendingActionId, 7);
      expect(message.actions.map((a) => a.status), [
        AgentActionStatus.completed,
        AgentActionStatus.pendingConfirmation,
        AgentActionStatus.failed,
        AgentActionStatus.cancelled,
      ]);
    });

    test('treats unknown statuses as failed, never as completed', () {
      final action = AgentAction.fromJson({'tool': 'x', 'status': 'weird'});
      expect(action.status, AgentActionStatus.failed);
    });

    test('tolerates missing fields', () {
      final message = AgentMessage.fromJson({});
      expect(message.role, 'assistant');
      expect(message.content, '');
      expect(message.actions, isEmpty);
    });
  });

  group('AgentPendingAction.fromJson', () {
    test('only pending actions produce a confirm card', () {
      expect(
        AgentPendingAction.fromJson({
          'id': 1,
          'summary': 's',
          'status': 'pending',
        })?.id,
        1,
      );
      expect(
        AgentPendingAction.fromJson({'id': 1, 'status': 'expired'}),
        isNull,
      );
      expect(
        AgentPendingAction.fromJson({'id': 1, 'status': 'executed'}),
        isNull,
      );
      expect(AgentPendingAction.fromJson(null), isNull);
    });
  });
}
