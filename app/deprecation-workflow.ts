import setupDeprecationWorkflow from 'ember-cli-deprecation-workflow';

setupDeprecationWorkflow({
  throwOnUnhandled: false,
  workflow: [
    {
      handler: 'silence',
      matchId: 'importing-inject-from-ember-service',
      matchMessage: '',
    },
  ],
});
