/* eslint-disable @typescript-eslint/no-base-to-string */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */

import { on } from '@ember/modifier';
import type RouterService from '@ember/routing/router-service';
import { service } from '@ember/service';
import { addHour, addMinute, format, parse } from '@formkit/tempo';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import pageTitle from 'ember-page-title/helpers/page-title';
import RouteTemplate from 'ember-route-template';
import { FORMAT } from 'ev/consts';
import { createSession } from 'ev/db';

export default RouteTemplate(
  <template>
    {{pageTitle "Nieuwe Sessie"}}

    <section>
      <NewSessionForm />
    </section>
  </template>,
);

class NewSessionForm extends Component<{
  Element: HTMLFormElement;
}> {
  @service declare router: RouterService;

  @tracked image: string = '';
  @tracked date: string = '';
  @tracked time: string = '';
  @tracked hours: string = '';
  @tracked minutes: string = '';
  @tracked totalKwh: string = '';

  @tracked submitting: boolean = false;

  processImage = async (event: Event): void => {
    const worker = await Tesseract.createWorker('eng', 1, {
      workerPath:
        'https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/worker.min.js',
    });

    const file = (event.target as HTMLInputElement).files[0];
    const {
      data: { text },
    } = (await worker.recognize(file)) as {
      data: { text: string };
    };

    const [, datetime] = /ACE0546278 (.*)/.exec(text) ?? ['', ''];
    const [, duration] = /Laadtijd: (.*)h/.exec(text) ?? ['', ''];
    const [, totalKwh] = /Totaal: (.*)kWh/.exec(text) ?? ['', ''];

    const [date, time]: [string, string] = datetime.split(' ');
    const [hours, minutes]: [string, string] = duration.split(':');

    this.image = await toBase64String(file);
    this.date = format(
      date ? parse(date, FORMAT.DATE_NL) : new Date(),
      FORMAT.DATE_US,
    );
    this.time = time ?? format(new Date(), FORMAT.TIME);
    this.hours = hours ?? '';
    this.minutes = minutes ?? '';
    this.totalKwh = totalKwh ?? '';
  };

  submit = async (event: SubmitEvent): void => {
    event.preventDefault();

    this.submitting = true;

    const form = new FormData(event.target);
    const date = String(form.get('date'));
    const time = String(form.get('time'));
    const parsed = parse(`${date} ${time}`, `${FORMAT.DATE_US} ${FORMAT.TIME}`);

    await createSession({
      id: Date.now(),
      start: addHour(
        addMinute(parsed, -Number(form.get('minutes'))),
        -Number(form.get('hours')),
      ).toISOString(),
      end: parsed.toISOString(),
      totalKwh: Number(form.get('totalKwh')),
    });

    this.router.transitionTo('sessions.index');
  };

  <template>
    <form {{on "submit" this.submit}} ...attributes>
      <label for="image">
        Afbeelding
      </label>
      <input
        accept="image/*"
        id="image"
        name="image"
        required
        type="file"
        {{on "change" this.processImage}}
      />

      {{#if this.image}}
        <img alt="Session" height="200" src={{this.image}} />

        <label for="date">
          Einddatum
        </label>
        <input id="date" name="date" required type="date" value={{this.date}} />

        <label for="time">
          Eindtijdstip
        </label>
        <input id="time" name="time" required type="time" value={{this.time}} />

        <label for="hours">
          Duur Uren
        </label>
        <input
          id="hours"
          min="0"
          name="hours"
          placeholder="10"
          required
          step="1"
          type="number"
          value={{this.hours}}
        />

        <label for="minutes">
          Duur Minuten
        </label>
        <input
          id="minutes"
          max="59"
          min="0"
          name="minutes"
          placeholder="5"
          required
          step="1"
          type="number"
          value={{this.minutes}}
        />

        <label for="totalKwh">
          Totaal kWh
        </label>
        <input
          id="totalKwh"
          min="0"
          name="totalKwh"
          placeholder="50.10"
          required
          step="0.01"
          type="number"
          value={{this.totalKwh}}
        />

        <button disabled={{this.submitting}} type="submit">
          {{#if this.submitting}}
            Sessie Opslaan...
          {{else}}
            Sessie Opslaan
          {{/if}}
        </button>
      {{/if}}
    </form>
  </template>
}

function toBase64String(file: File): Promise<string> {
  const promise: Promise<string> = new Promise((resolve, reject) => {
    const fileReader = new FileReader();

    fileReader.onerror = reject;
    fileReader.onload = (): Promise<string> =>
      resolve(fileReader.result as string);
    fileReader.readAsDataURL(file);
  });

  return promise;
}
