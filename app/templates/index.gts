import { on } from '@ember/modifier';
import RouteTemplate from 'ember-route-template';
import { auth as authenticate } from 'ev/auth';

export default RouteTemplate(
  <template>
    {{outlet}}
    <section class="fullscreen">
      <form {{on "submit" auth}}>
        <label for="password">Wachtwoord</label>
        <input id="password" name="password" type="text" />
        <button type="submit">Aanmelden</button>
      </form>
    </section>
  </template>,
);

function auth(event: SubmitEvent): void {
  event.preventDefault();

  const form = new FormData(event.target);

  authenticate(form.get('password'));
}
