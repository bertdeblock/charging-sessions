import { concat, fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { format } from '@formkit/tempo';
import RouteTemplate from 'ember-route-template';
import { FORMAT } from 'ev/consts';
import { clearStorage, deleteSession } from 'ev/db';
import type { Session } from 'ev/types';

export default RouteTemplate(
  <template>
    <section>
      <button type="button" {{on "click" clearStorage}}>
        Herladen
      </button>
      {{#if @model.sessions.length}}
        <p>
          <em>Totaal: {{totalKwh @model.sessions}}kWh</em>
        </p>
        <p>
          <em>Geschatte kosten: €{{cost @model.sessions}}</em>
        </p>
        <table>
          <thead>
            <tr>
              <th>Start / Einde</th>
              <th>Totaal</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {{#each @model.sessions key="id" as |session|}}
              <tr class={{if (isNew session) "highlight"}}>
                <td>
                  <div>
                    <em>
                      {{format
                        session.start
                        (concat FORMAT.TIME "\h - " FORMAT.DATE_NL)
                      }}
                    </em>
                  </div>
                  <div>
                    <b>
                      {{format
                        session.end
                        (concat FORMAT.TIME "\h - " FORMAT.DATE_NL)
                      }}
                    </b>
                  </div>
                  <div>
                    <em>{{session.id}}</em>
                  </div>
                </td>
                <td>
                  <b>
                    {{session.totalKwh}}kWh
                  </b>
                </td>
                <td>
                  <button
                    type="button"
                    {{on "click" (fn deleteSession session)}}
                  >
                    <svg
                      fill="currentColor"
                      height="16"
                      viewBox="0 0 448 512"
                      width="16"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        d="M135.2 17.7L128 32 32 32C14.3 32 0 46.3 0 64S14.3 96 32 96l384 0c17.7 0 32-14.3 32-32s-14.3-32-32-32l-96 0-7.2-14.3C307.4 6.8 296.3 0 284.2 0L163.8 0c-12.1 0-23.2 6.8-28.6 17.7zM416 128L32 128 53.2 467c1.6 25.3 22.6 45 47.9 45l245.8 0c25.3 0 46.3-19.7 47.9-45L416 128z"
                      />
                    </svg>
                  </button>
                </td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      {{else}}
        <p>
          <em>Nog geen sessies.</em>
        </p>
      {{/if}}
    </section>
  </template>,
);

function cost(sessions: Session[]): number {
  return totalKwh(sessions) * 0.33;
}

function isNew(session: Session): boolean {
  return Date.now() - session.id < 60000;
}

function totalKwh(sessions: Session[]): number {
  return sessions.reduce((totalKwh, session) => totalKwh + session.totalKwh, 0);
}
