import { module, test } from 'qunit';
import { setupTest } from 'ev/tests/helpers';

module('Unit | Route | sessions', function (hooks) {
  setupTest(hooks);

  test('it exists', function (assert) {
    const route = this.owner.lookup('route:sessions');
    assert.ok(route);
  });
});
