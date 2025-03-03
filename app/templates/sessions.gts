import { LinkTo } from '@ember/routing';
import RouteTemplate from 'ember-route-template';

export default RouteTemplate(
  <template>
    <header>
      <nav>
        <ul>
          <li>
            <LinkTo @route="sessions.index">Sessies</LinkTo>
          </li>
          <li>
            <LinkTo @route="sessions.new">Nieuwe sessie</LinkTo>
          </li>
        </ul>
      </nav>
    </header>
    {{outlet}}
  </template>,
);
