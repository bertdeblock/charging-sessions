import Route from '@ember/routing/route';
import { readSessions } from 'ev/db';
import type { SessionsData } from 'ev/types';

export default class SessionsIndexRoute extends Route {
  async model(): Promise<SessionsData> {
    return readSessions();
  }
}
