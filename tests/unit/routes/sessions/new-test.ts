import { module, test } from 'qunit';
import { setupTest } from 'ev/tests/helpers';

module('Unit | Route | sessions/new', function (hooks) {
  setupTest(hooks);

  test('it exists', function (assert) {
    let route = this.owner.lookup('route:sessions/new');
    assert.ok(route);
  });
});
