/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */

import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import type RouterService from '@ember/routing/router-service';
import { service } from '@ember/service';
import { addHour, addMinute, format, parse } from '@formkit/tempo';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import RouteTemplate from 'ember-route-template';
import { FORMAT } from 'ev/consts';
import { createSession } from 'ev/db';

export default RouteTemplate(
  <template>
    <section>
      <NewSessionForm />
    </section>
  </template>,
);

let worker;

class NewSessionForm extends Component<{
  Element: HTMLFormElement;
}> {
  @service declare router: RouterService;

  @tracked text: string = '';
  @tracked image: string = '';
  @tracked date: string = '';
  @tracked time: string = '';
  @tracked hours: string = '';
  @tracked minutes: string = '';
  @tracked totalKwh: string = '';

  @tracked processingImage: boolean = false;
  @tracked submitting: boolean = false;

  processImage = async (event: Event): void => {
    this.processingImage = true;

    if (worker === undefined) {
      worker = await Tesseract.createWorker('nld', 1, {
        workerPath:
          'https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/worker.min.js',
      });
    }

    const file = (event.target as HTMLInputElement).files[0];
    const { data } = (await worker.recognize(file)) as {
      data: { text: string };
    };

    const text = data.text.toLowerCase();

    // `ACE0546278`, but we omit `ACE`, because it is not always readable:
    const [, datetime] = /0546278 (.*)/.exec(text) ?? ['', ''];
    const [, duration] = /laadtijd: (.*)h/.exec(text) ?? ['', ''];
    const [, totalKwh] = /totaal: (.*)kwh/.exec(text) ?? ['', ''];

    const datetimeParts = datetime.split(' ');
    const date = datetimeParts.at(-2).replace(/:/g, '-');
    const time = datetimeParts.at(-1);
    const [hours, minutes]: [string, string] = duration.split(':');

    try {
      this.date = date ? format(parse(date, 'DD-MM-YYYY'), FORMAT.DATE_US) : '';
    } catch (error) {
      console.error(error);
    }

    this.text = text;
    this.image = await toBase64String(file);
    this.time = time ?? '';
    this.hours = hours ?? '';
    this.minutes = minutes ?? '';
    this.totalKwh = totalKwh ?? '';

    console.log({
      image: this.image,
      date: this.date,
      time: this.time,
      hours: this.hours,
      minutes: this.minutes,
      totalKwh: this.totalKwh,
    });

    this.processingImage = false;
  };

  submit = async (event: SubmitEvent): void => {
    event.preventDefault();

    const parsed = parse(
      `${this.date} ${this.time}`,
      `${FORMAT.DATE_US} ${FORMAT.TIME}`,
    );

    const newSession = {
      id: Date.now(),
      start: addHour(
        addMinute(parsed, -Number(this.minutes)),
        -Number(this.hours),
      ).toISOString(),
      end: parsed.toISOString(),
      totalKwh: Number(this.totalKwh),
    };

    console.log(newSession);

    this.submitting = true;

    await createSession(newSession);

    this.router.transitionTo('sessions.index');
  };

  updateValue = (key: string, event: Event): void => {
    this[key] = event.target.value;
  };

  <template>
    <form {{on "submit" this.submit}} ...attributes>
      <button disabled={{this.processingImage}} type="button">
        {{#if this.processingImage}}
          Afbeelding opladen...
        {{else}}
          Afbeelding kiezen
        {{/if}}
        {{! template-lint-disable no-nested-interactive }}
        <input
          aria-label="Afbeelding Kiezen"
          accept="image/*"
          disabled={{this.processingImage}}
          required
          type="file"
          {{on "change" this.processImage}}
        />
      </button>

      {{#if this.image}}
        <img alt="Gekozen afbeelding van laadpaal" src={{this.image}} />

        <pre>{{this.text}}</pre>

        <label for="date">
          Einddatum
        </label>
        <input
          id="date"
          required
          type="date"
          value={{this.date}}
          {{on "input" (fn this.updateValue "date")}}
        />

        <label for="time">
          Eindtijdstip
        </label>
        <input
          id="time"
          required
          type="time"
          value={{this.time}}
          {{on "input" (fn this.updateValue "time")}}
        />

        <label for="hours">
          Duur uren
        </label>
        <input
          id="hours"
          min="0"
          placeholder="10"
          required
          step="1"
          type="number"
          value={{this.hours}}
          {{on "input" (fn this.updateValue "hours")}}
        />

        <label for="minutes">
          Duur minuten
        </label>
        <input
          id="minutes"
          max="59"
          min="0"
          placeholder="5"
          required
          step="1"
          type="number"
          value={{this.minutes}}
          {{on "input" (fn this.updateValue "minutes")}}
        />

        <label for="totalKwh">
          Totaal kWh
        </label>
        <input
          id="totalKwh"
          min="0"
          placeholder="50.10"
          required
          step="0.01"
          type="number"
          value={{this.totalKwh}}
          {{on "input" (fn this.updateValue "totalKwh")}}
        />

        <button disabled={{this.submitting}} type="submit">
          {{#if this.submitting}}
            Sessie opslaan...
          {{else}}
            Sessie opslaan
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
